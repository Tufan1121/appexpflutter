import 'package:appexpflutter_update/features/punto_venta/domain/entities/detalle_pedido_entity.dart';

class UtilsVenta {
  static double total = 0;
  static List<DetallePedidoEntity> listProductsOrder = [];

  // Datos para el envío
  static double shippingCost = 0;
  static String shippingCarrier = '';
  static String shippingServiceDescription = '';

  static bool get hasShipping => shippingCost > 0;

  static double get totalWithShipping => total + shippingCost;

  static void setShipping(double cost, String carrier, String serviceDescription) {
    shippingCost = cost;
    shippingCarrier = carrier;
    shippingServiceDescription = serviceDescription;
  }

  static void clearShipping() {
    shippingCost = 0;
    shippingCarrier = '';
    shippingServiceDescription = '';
  }

  static void clearAll() {
    total = 0;
    listProductsOrder = [];
    clearShipping();
  }
}
