/// Respuesta cruda de `POST /ship/rate/` de envia.com.
///
/// envia.com responde HTTP 200 con `meta: "error"` cuando la paquetería
/// rechaza el bulto (dimensiones, peso, cobertura); ese mensaje es el que se
/// le muestra a ventas como motivo de rechazo.
class ShippingRateResponse {
  final String meta;
  final List<ShippingRate> data;
  final String? error;

  ShippingRateResponse({
    required this.meta,
    required this.data,
    this.error,
  });

  bool get isError => meta == 'error' || error != null;

  factory ShippingRateResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta']?.toString() ?? '';
    String? error;
    if (meta == 'error') {
      final err = json['error'];
      if (err is Map) {
        error = (err['message'] ?? err['description'])?.toString();
      } else if (err != null) {
        error = err.toString();
      }
      error = (error == null || error.trim().isEmpty)
          ? 'Rechazado por la paquetería'
          : error.trim();
    }
    return ShippingRateResponse(
      meta: meta,
      data: (json['data'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ShippingRate.fromJson)
              .toList() ??
          [],
      error: error,
    );
  }

  factory ShippingRateResponse.error(String message) {
    return ShippingRateResponse(
      meta: 'error',
      data: [],
      error: message,
    );
  }
}

/// Una tarifa tal como la regresa envia.com. `totalPrice` es el precio
/// ORIGINAL (sin margen); el margen por tipo de envío lo aplica el
/// repositorio al construir `ShippingOption`.
class ShippingRate {
  final int carrierId;
  final String carrier;
  final String carrierDescription;
  final int serviceId;
  final String service;
  final String serviceDescription;
  final String deliveryEstimate;
  final DeliveryDate? deliveryDate;
  final double totalPrice;
  final String currency;

  /// 0 = puerta a puerta; 1/2/3 = pasa por sucursal (ocurre).
  final int dropOff;
  final String dropOffDescription;

  /// Sucursales (ocurre) que envia.com regresa con la tarifa. Solo vienen en
  /// servicios con `dropOff` distinto de 0.
  final List<ShippingBranch> branches;

  ShippingRate({
    required this.carrierId,
    required this.carrier,
    required this.carrierDescription,
    required this.serviceId,
    required this.service,
    required this.serviceDescription,
    required this.deliveryEstimate,
    this.deliveryDate,
    required this.totalPrice,
    required this.currency,
    this.dropOff = 0,
    this.dropOffDescription = '',
    this.branches = const [],
  });

  bool get esOcurre => dropOff != 0;

  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    return ShippingRate(
      carrierId: _toInt(json['carrierId']),
      carrier: json['carrier']?.toString() ?? '',
      carrierDescription: json['carrierDescription']?.toString() ?? '',
      serviceId: _toInt(json['serviceId']),
      service: json['service']?.toString() ?? '',
      serviceDescription: json['serviceDescription']?.toString() ?? '',
      deliveryEstimate: json['deliveryEstimate']?.toString() ?? '',
      deliveryDate: json['deliveryDate'] is Map<String, dynamic>
          ? DeliveryDate.fromJson(json['deliveryDate'] as Map<String, dynamic>)
          : null,
      totalPrice: _toDouble(json['totalPrice']),
      currency: json['currency']?.toString() ?? 'MXN',
      dropOff: _toInt(json['dropOff']),
      dropOffDescription: json['dropOffDescription']?.toString() ?? '',
      branches: (json['branches'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ShippingBranch.fromJson)
              .toList() ??
          const [],
    );
  }
}

/// Sucursal de la paquetería donde el cliente recoge (entrega en ocurre).
class ShippingBranch {
  final String id;
  final String nombre;
  final String dir;

  /// Distancia al CP destino en km (null si la paquetería no la manda).
  final double? km;

  const ShippingBranch({
    required this.id,
    required this.nombre,
    required this.dir,
    this.km,
  });

  factory ShippingBranch.fromJson(Map<String, dynamic> json) {
    final ad = json['address'];
    final adMap = ad is Map<String, dynamic> ? ad : const <String, dynamic>{};
    final dir = [
      adMap['street'],
      adMap['number'],
      adMap['city'] ?? adMap['locality'],
      adMap['state'],
    ]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .map((e) => e.toString())
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final nombre = (json['reference'] ?? json['branch_code'] ?? 'Sucursal')
        .toString()
        .trim();
    final distancia = json['distance'];
    double? km;
    if (distancia != null) {
      final d = double.tryParse(distancia.toString());
      if (d != null) km = (d * 10).round() / 10;
    }
    return ShippingBranch(
      id: (json['branch_id'] ?? json['branch_code'] ?? '').toString(),
      nombre: nombre.isEmpty ? 'Sucursal' : nombre,
      dir: dir,
      km: km,
    );
  }

  /// "Nombre (3.2 km) · dirección"
  String get etiqueta {
    final buf = StringBuffer(nombre);
    if (km != null) buf.write(' ($km km)');
    if (dir.isNotEmpty) buf.write(' · $dir');
    return buf.toString();
  }
}

class DeliveryDate {
  final String date;
  final int dateDifference;
  final String timeUnit;
  final String time;

  DeliveryDate({
    required this.date,
    required this.dateDifference,
    required this.timeUnit,
    required this.time,
  });

  factory DeliveryDate.fromJson(Map<String, dynamic> json) {
    return DeliveryDate(
      date: json['date']?.toString() ?? '',
      dateDifference: _toInt(json['dateDifference']),
      timeUnit: json['timeUnit']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
