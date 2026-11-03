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

  /// Total incluyendo envío
  static double get totalWithShipping => total + shippingCost;

  /// Servicio(s) y ruta de los envíos, para observaciones.
  static String get shippingObserva => envios.observaAgrupada;

  static void clearShipping() => envios.clear();

  /// Partidas a guardar: los productos y, si hay envío, la partida ENVIO
  /// (clave2 vacía, igual que la que arma mainExpo en pretikd).
  static List<DetallePedidoEntity> get partidasConEnvio => [
        ...listProductsOrder,
        if (hasShipping)
          DetallePedidoEntity(
            idPedido: 0,
            clave: 'ENVIO',
            clave2: '',
            cantidad: 1,
            precio: shippingCost,
          ),
      ];
}
