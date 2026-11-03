import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';

/// Empaque que elige el usuario para la cotización como CARGA (LTL). Como
/// paquete siempre se cotiza como caja. Misma lista que en galería
/// (`busquedaglobal.html` / `cotizaciones.html`).
enum ShipEmpaque {
  roll('roll', 'Rollo / pieza suelta'),
  pieceNoPallet('piece_no_pallet', 'Pieza sin pallet'),
  pallet('pallet', 'Tarima');

  const ShipEmpaque(this.apiValue, this.label);

  /// Valor que se manda a envia.com en `packages[].type`.
  final String apiValue;
  final String label;
}

/// Tipo de entrega. Se filtra por este valor para que el "mejor precio" no
/// mezcle un ocurre con una entrega a domicilio.
enum ShipEntrega {
  domicilio('A domicilio (puerta a puerta)', 'entrega a domicilio'),
  ocurre('En ocurre (el cliente recoge en sucursal)', 'entrega en ocurre');

  const ShipEntrega(this.label, this.descripcion);

  final String label;
  final String descripcion;
}

/// Modo de envío: paquetería convencional (shipment.type 1) o carga / LTL
/// (shipment.type 2).
enum ShipModo {
  paquete(1, 'Paquete'),
  carga(2, 'Carga');

  const ShipModo(this.shipmentType, this.label);

  final int shipmentType;
  final String label;

  static ShipModo fromType(int type) =>
      type == 2 ? ShipModo.carga : ShipModo.paquete;
}

/// Una consulta a envia.com: paquetería + tipo de envío + empaque.
class ShipAttempt {
  final String carrier;
  final ShipModo modo;

  /// `packages[].type`: box, roll, tied, piece_no_pallet, pallet.
  final String pkg;

  const ShipAttempt({
    required this.carrier,
    required this.modo,
    required this.pkg,
  });
}

/// Paquetería que rechazó el bulto, con el motivo que regresó envia.com.
class ShipRejection {
  final String carrier;
  final ShipModo modo;

  /// Etiqueta del empaque con el que se intentó (Caja, Rollo, Tarima...).
  final String empaque;
  final String motivo;

  const ShipRejection({
    required this.carrier,
    required this.modo,
    required this.empaque,
    required this.motivo,
  });
}

/// Una tarifa ya procesada: con margen aplicado, modo, empaque y datos de
/// ocurre. Equivale a las filas de `allRates` en galería.
class ShippingOption {
  /// Clave de la paquetería en envia.com (paquetexpress, fedexFreight, ...).
  final String carrier;
  final String carrierDescription;
  final ShipModo modo;

  /// `packages[].type` con el que se cotizó.
  final String empaque;
  final int serviceId;
  final String service;
  final String serviceDescription;
  final String deliveryEstimate;
  final DeliveryDate? deliveryDate;
  final int dropOff;
  final bool esOcurre;

  /// "Puerta a puerta" o la descripción del ocurre que manda la paquetería.
  final String entregaDesc;

  /// Sucursales ordenadas por distancia (máx. 8). Solo en ocurre.
  final List<ShippingBranch> branches;

  /// Precio que regresó envia.com, sin margen.
  final double originalPrice;

  /// Precio por guía con margen (30% paquete, 15% carga) redondeado a la
  /// centena superior.
  final double price;
  final String currency;

  const ShippingOption({
    required this.carrier,
    required this.carrierDescription,
    required this.modo,
    required this.empaque,
    required this.serviceId,
    required this.service,
    required this.serviceDescription,
    required this.deliveryEstimate,
    required this.deliveryDate,
    required this.dropOff,
    required this.esOcurre,
    required this.entregaDesc,
    required this.branches,
    required this.originalPrice,
    required this.price,
    required this.currency,
  });

  /// Texto del tiempo de entrega ("2 días", "3 días hábiles"...) o vacío.
  String get tiempoEntrega {
    if (deliveryEstimate.trim().isNotEmpty) return deliveryEstimate.trim();
    final dd = deliveryDate;
    if (dd != null && dd.dateDifference > 0) {
      return '${dd.dateDifference} ${dd.timeUnit.isNotEmpty ? dd.timeUnit : 'días'}';
    }
    return '';
  }
}

/// Resultado de cotizar UN bulto (largo × ancho × alto, peso) con todas las
/// paqueterías, en paquete y en carga.
class ShippingQuoteResult {
  /// Tarifas aceptadas, ya filtradas por tipo de entrega y ordenadas por
  /// precio.
  final List<ShippingOption> options;

  /// Paqueterías que rechazaron el bulto o cuyos servicios se descartaron
  /// por el tipo de entrega elegido.
  final List<ShipRejection> rechazos;

  /// "120×30×30 cm · 12 kg"
  final String dims;

  const ShippingQuoteResult({
    required this.options,
    required this.rechazos,
    required this.dims,
  });

  List<ShippingOption> get paquete =>
      options.where((o) => o.modo == ShipModo.paquete).toList();

  List<ShippingOption> get carga =>
      options.where((o) => o.modo == ShipModo.carga).toList();
}
