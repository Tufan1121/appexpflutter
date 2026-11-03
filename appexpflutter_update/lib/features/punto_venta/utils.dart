import 'package:appexpflutter_update/features/cotizador_envio/data/models/envio_parcial.dart';
import 'package:punto_venta/domain/entities/detalle_pedido_entity.dart';

class UtilsVenta {
  /// Total de productos (sin envío)
  static double total = 0;
  static List<DetallePedidoEntity> listProductsOrder = [];

  // ---------------------------------------------------------------------------
  // Envío: una o varias cotizaciones (p. ej. paquete para un tapete y Big
  // Ticket para otro) que se guardan juntas en UNA partida ENVIO.
  // ---------------------------------------------------------------------------

  static final EnviosCotizados envios = EnviosCotizados();

  /// Suma de los envíos (0 si no hay envío), en pesos enteros.
  static double get shippingCost => envios.total.roundToDouble();

  static bool get hasShipping => shippingCost > 0;

  // ---------------------------------------------------------------------------
  // Servicios (p. ej. lavado de tapete) y anticipos: partidas sin mercancía
  // con clave SERVICIO / ANTICIPO y la descripción en pretikd.observa, igual
  // que el punto de venta de la galería.
  // ---------------------------------------------------------------------------

  static final List<ServicioVenta> servicios = [];

  static double get serviciosTotal =>
      servicios.fold(0.0, (suma, s) => suma + s.precio);

  static bool get hasServicios => servicios.isNotEmpty;

  static void clearServicios() => servicios.clear();

  /// Total incluyendo servicios, anticipos y envío
  static double get totalWithShipping =>
      total + serviciosTotal + shippingCost;

  /// Servicio(s) y ruta de los envíos, para observaciones.
  static String get shippingObserva => envios.observaAgrupada;

  static void clearShipping() => envios.clear();

  /// Partidas a guardar: los productos y, si hay envío, la partida ENVIO
  /// (clave2 vacía, igual que la que arma mainExpo en pretikd).
  static List<DetallePedidoEntity> get partidasConEnvio => [
        ...listProductsOrder,
        for (final s in servicios)
          DetallePedidoEntity(
            idPedido: 0,
            clave: s.clave,
            clave2: '',
            cantidad: 1,
            precio: s.precio,
            observa: s.descripcion,
          ),
        if (hasShipping)
          DetallePedidoEntity(
            idPedido: 0,
            clave: 'ENVIO',
            clave2: '',
            cantidad: 1,
            precio: shippingCost,
            observa: shippingObserva,
          ),
      ];
}

/// Servicio o anticipo capturado en el ticket.
class ServicioVenta {
  /// 'SERVICIO' o 'ANTICIPO'
  final String clave;
  final String descripcion;
  final double precio;

  const ServicioVenta(
      {required this.clave, required this.descripcion, required this.precio});

  bool get esAnticipo => clave == 'ANTICIPO';
}
