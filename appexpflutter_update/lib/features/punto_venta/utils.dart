import 'package:appexpflutter_update/features/punto_venta/domain/entities/detalle_pedido_entity.dart';

class UtilsVenta {
  static double total = 0;
  static List<DetallePedidoEntity> listProductsOrder = [];

  // Datos para el envío
  static double shippingCost = 0;
  static String shippingCarrier = '';
  static String shippingServiceDescription = '';
  static String shippingBreakdown = '';

  static bool get hasShipping => shippingCost > 0;

  static double get totalWithShipping => total + shippingCost;
  
  /// Obtiene la descripción completa del envío incluyendo desglose
  static String get fullShippingDescription {
    if (shippingBreakdown.isEmpty) {
      return shippingServiceDescription;
    }
    return '$shippingServiceDescription\n$shippingBreakdown';
  }

  static void setShipping(double cost, String carrier, String serviceDescription, [String breakdown = '']) {
    shippingCost = cost;
    shippingCarrier = carrier;
    shippingServiceDescription = serviceDescription;
    shippingBreakdown = breakdown;
  }

  static void clearShipping() {
    print('⚠️ [UtilsVenta] clearShipping() CALLED! shippingCost was: $shippingCost');
    print(StackTrace.current);
    shippingCost = 0;
    shippingCarrier = '';
    shippingServiceDescription = '';
    shippingBreakdown = '';
  }

  static void clearAll() {
    print('⚠️ [UtilsVenta] clearAll() CALLED! total=$total, shippingCost=$shippingCost');
    print(StackTrace.current);
    total = 0;
    listProductsOrder = [];
    clearShipping();
  }
}

