import 'package:dio/dio.dart';

import 'package:appexpflutter_update/features/cotizador_envio/data/datasources/envia_api_client.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_quote.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_request.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/zipcode_info.dart';

/// Origen y destino de una cotización (CP, ciudad, estado y colonia).
class ShipRoute {
  final String originPostalCode;
  final String originCity;
  final String originState;
  final String originDistrict;
  final String destinationPostalCode;
  final String destinationCity;
  final String destinationState;
  final String destinationDistrict;

  const ShipRoute({
    required this.originPostalCode,
    required this.originCity,
    required this.originState,
    required this.originDistrict,
    required this.destinationPostalCode,
    required this.destinationCity,
    required this.destinationState,
    required this.destinationDistrict,
  });
}

/// Cotizador contra envia.com. Misma configuración que galería
/// (`busquedaglobal.html` / `cotizaciones.html`): cada bulto se cotiza como
/// PAQUETE (shipment.type 1, empaque caja) con las paqueterías
/// convencionales y como CARGA / LTL (shipment.type 2) con las de flete.
/// Lo que cada una rechace se regresa con su motivo en vez de descartarse
/// en silencio.
class ShippingRepository {
  final EnviaApiClient _apiClient;

  ShippingRepository() : _apiClient = EnviaApiClient();

  /// Paqueterías que se cotizan como paquete (siempre con empaque `box`).
  static const List<String> parcelCarriers = [
    'paquetexpress',
    'fedex',
    'dhl',
    'estafeta',
    'ups',
    'sendex',
  ];

  /// Carga: tipos de empaque configurados por paquetería en envia.com
  /// (probado contra /ship/rate el 2026-09-09). Orden = preferencia.
  ///  - tresguerras piece_no_pallet = servicio "Big Ticket", hasta 350 cm
  ///  - almex roll acepta rollos de 4 m; pallet máx. 280 cm
  ///  - paquetexpress LTL pide más de 61 kg y máx. 300 cm
  static const Map<String, List<String>> ltlCarriers = {
    'almex': ['roll', 'tied', 'pallet', 'piece_no_pallet'],
    'tresguerras': ['piece_no_pallet', 'pallet'],
    'paquetexpress': ['pallet'],
    'fedexFreight': ['pallet'],
    'estafeta': ['pallet', 'piece_no_pallet'],
    'castores': ['pallet'],
  };

  /// Empaque elegido por el usuario para carga → orden de fallback por
  /// paquetería.
  static const Map<ShipEmpaque, List<String>> empaquePref = {
    ShipEmpaque.roll: ['roll', 'piece_no_pallet', 'pallet'],
    ShipEmpaque.pieceNoPallet: ['piece_no_pallet', 'pallet'],
    ShipEmpaque.pallet: ['pallet'],
  };

  static const Map<String, String> empaqueLabel = {
    'box': 'Caja',
    'roll': 'Rollo',
    'tied': 'Atado',
    'piece_no_pallet': 'Pieza sin pallet',
    'pallet': 'Tarima',
  };

  static String labelEmpaque(String pkg) => empaqueLabel[pkg] ?? pkg;

  /// Margen sobre el precio de envia.com por modo. El resultado se redondea
  /// a la centena superior.
  static const Map<ShipModo, double> markup = {
    ShipModo.paquete: 1.30,
    ShipModo.carga: 1.15,
  };

  /// Precio con margen redondeado a la centena superior.
  static double conMargen(double original, ShipModo modo) {
    final withMarkup = original * (markup[modo] ?? markup[ShipModo.paquete]!);
    return (withMarkup / 100).ceilToDouble() * 100;
  }

  /// Máximo de sucursales que se listan por tarifa en ocurre.
  static const int maxBranches = 8;

  /// Lista de consultas (paquete + carga) según el empaque elegido.
  static List<ShipAttempt> shipAttempts(ShipEmpaque empaque) {
    final pref = empaquePref[empaque] ?? empaquePref[ShipEmpaque.roll]!;
    final list = <ShipAttempt>[
      for (final carrier in parcelCarriers)
        ShipAttempt(carrier: carrier, modo: ShipModo.paquete, pkg: 'box'),
    ];
    ltlCarriers.forEach((carrier, supported) {
      final pkg = pref.firstWhere(supported.contains, orElse: () => supported.first);
      list.add(ShipAttempt(carrier: carrier, modo: ShipModo.carga, pkg: pkg));
    });
    return list;
  }

  /// Obtiene información del código postal desde la API de geocodes
  /// Solo necesita el código postal, devuelve ciudad, estado, colonias, etc.
  Future<ZipcodeInfo?> getZipcodeInfo(String zipCode) async {
    try {
      final response = await _apiClient.getZipcodeInfo(zipCode);

      if (response.statusCode == 200 && response.data != null) {
        // La API devuelve un array, tomamos el primer elemento
        final dataList = response.data as List<dynamic>;
        if (dataList.isNotEmpty) {
          return ZipcodeInfo.fromJson(dataList[0] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cotiza UN bulto con todas las paqueterías (paquete y carga) en
  /// paralelo. Regresa las tarifas aceptadas (con margen, filtradas por tipo
  /// de entrega y ordenadas por precio) y los rechazos con su motivo.
  ///
  /// Siempre se cotiza `amount: 1`; el total por producto es precio × número
  /// de guías (igual que en galería).
  Future<ShippingQuoteResult> quote({
    required ShipRoute route,
    required double largo,
    required double ancho,
    required double alto,
    required double peso,
    ShipEmpaque empaque = ShipEmpaque.roll,
    ShipEntrega entrega = ShipEntrega.domicilio,
  }) async {
    final attempts = shipAttempts(empaque);
    final results = await Future.wait(attempts.map((a) => _rate(
          a,
          route: route,
          largo: largo,
          ancho: ancho,
          alto: alto,
          peso: peso,
        )));

    final options = <ShippingOption>[];
    final rechazos = <ShipRejection>[];
    final quiereOcurre = entrega == ShipEntrega.ocurre;

    for (var i = 0; i < attempts.length; i++) {
      final a = attempts[i];
      final r = results[i];
      if (r.isError) {
        rechazos.add(ShipRejection(
          carrier: a.carrier,
          modo: a.modo,
          empaque: labelEmpaque(a.pkg),
          motivo: r.error ?? 'Rechazado por la paquetería',
        ));
        continue;
      }
      var descartados = 0;
      for (final rate in r.data) {
        // dropOff: 0 = puerta a puerta; 1/2/3 = pasa por sucursal (ocurre).
        // Se filtra por el tipo de entrega elegido para no mezclar ambos.
        final esOcurre = rate.esOcurre;
        if (esOcurre != quiereOcurre) {
          descartados++;
          continue;
        }
        final branches = esOcurre ? _sortBranches(rate.branches) : const <ShippingBranch>[];
        options.add(ShippingOption(
          carrier: a.carrier,
          carrierDescription:
              rate.carrierDescription.isNotEmpty ? rate.carrierDescription : a.carrier,
          modo: a.modo,
          empaque: a.pkg,
          serviceId: rate.serviceId,
          service: rate.service,
          serviceDescription:
              rate.serviceDescription.isNotEmpty ? rate.serviceDescription : rate.service,
          deliveryEstimate: rate.deliveryEstimate,
          deliveryDate: rate.deliveryDate,
          dropOff: rate.dropOff,
          esOcurre: esOcurre,
          entregaDesc: esOcurre
              ? (rate.dropOffDescription.isNotEmpty ? rate.dropOffDescription : 'Ocurre')
              : 'Puerta a puerta',
          branches: branches,
          originalPrice: rate.totalPrice,
          price: conMargen(rate.totalPrice, a.modo),
          currency: rate.currency,
        ));
      }
      if (descartados > 0) {
        final s = descartados != 1 ? 's' : '';
        rechazos.add(ShipRejection(
          carrier: a.carrier,
          modo: a.modo,
          empaque: labelEmpaque(a.pkg),
          motivo:
              '$descartados servicio$s ${quiereOcurre ? 'a domicilio' : 'ocurre'} descartado$s por el tipo de entrega elegido',
        ));
      }
    }

    options.sort((a, b) => a.price.compareTo(b.price));

    return ShippingQuoteResult(
      options: options,
      rechazos: rechazos,
      dims: '${_fmt(largo)}×${_fmt(ancho)}×${_fmt(alto)} cm · ${_fmt(peso)} kg',
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  static List<ShippingBranch> _sortBranches(List<ShippingBranch> branches) {
    final list = List<ShippingBranch>.from(branches)
      ..sort((a, b) => (a.km ?? 9999).compareTo(b.km ?? 9999));
    return list.length > maxBranches ? list.sublist(0, maxBranches) : list;
  }

  /// Una consulta a envia.com. Nunca lanza: los errores se regresan como
  /// `ShippingRateResponse.error(...)` con el motivo para ventas.
  Future<ShippingRateResponse> _rate(
    ShipAttempt attempt, {
    required ShipRoute route,
    required double largo,
    required double ancho,
    required double alto,
    required double peso,
  }) async {
    // Tres Guerras cobra mínimo 30 kg en carga; con menos rechaza la cotización.
    final effectiveWeight =
        (attempt.carrier == 'tresguerras' && peso < 30) ? 30.0 : peso;

    final request = ShippingRateRequest(
      origin: Origin(
        postalCode: route.originPostalCode,
        city: route.originCity,
        state: route.originState,
        district: route.originDistrict,
      ),
      destination: Destination(
        postalCode: route.destinationPostalCode,
        city: route.destinationCity,
        state: route.destinationState,
        district: route.destinationDistrict,
      ),
      packages: [
        Package(
          amount: 1,
          type: attempt.pkg,
          dimensions: Dimensions(length: largo, width: ancho, height: alto),
          weight: effectiveWeight,
        ),
      ],
      shipment: Shipment(
        carrier: attempt.carrier,
        type: attempt.modo.shipmentType,
      ),
      settings: Settings(),
    );

    try {
      final response = await _apiClient.post('/ship/rate/', data: request.toJson());
      return _parse(response.statusCode, response.data);
    } on DioException catch (e) {
      final res = e.response;
      if (res != null) return _parse(res.statusCode, res.data);
      final msg = e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout
          ? 'Sin respuesta de envia.com (tiempo agotado)'
          : (e.message ?? 'Sin respuesta de envia.com');
      return ShippingRateResponse.error(msg);
    } catch (e) {
      return ShippingRateResponse.error('Sin respuesta de envia.com');
    }
  }

  static ShippingRateResponse _parse(int? status, dynamic data) {
    if (data is Map<String, dynamic>) {
      final parsed = ShippingRateResponse.fromJson(data);
      if (parsed.isError) return parsed;
      if (status != null && status >= 400) {
        return ShippingRateResponse.error('Error HTTP $status');
      }
      if (parsed.data.isEmpty) {
        return ShippingRateResponse.error('Sin servicio para esta ruta');
      }
      return parsed;
    }
    if (status != null && status >= 400) {
      return ShippingRateResponse.error('Error HTTP $status');
    }
    return ShippingRateResponse.error('Sin servicio para esta ruta');
  }
}
