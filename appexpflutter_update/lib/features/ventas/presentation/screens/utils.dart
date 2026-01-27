import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';

class UtilsVenta {
  /// Total de productos (sin envío)
  static double total = 0;
  
  /// Lista de productos en el pedido
  static List<DetallePedidoEntity> listProductsOrder = [];
  
  /// Costo del envío seleccionado (0 si no hay envío)
  static double shippingCost = 0;
  
  /// Nombre del carrier seleccionado (vacío si no hay envío)
  static String shippingCarrier = '';
  
  /// Descripción del servicio de envío (vacío si no hay envío)
  static String shippingServiceDescription = '';
  
  /// Indica si se ha seleccionado un envío
  static bool get hasShipping => shippingCost > 0;
  
  /// Total incluyendo envío
  static double get totalWithShipping => total + shippingCost;
  
  /// Establece el envío seleccionado
  static void setShipping({
    required double cost,
    required String carrier,
    required String serviceDescription,
  }) {
    shippingCost = cost;
    shippingCarrier = carrier;
    shippingServiceDescription = serviceDescription;
  }
  
  /// Limpia la información del envío
  static void clearShipping() {
    shippingCost = 0;
    shippingCarrier = '';
    shippingServiceDescription = '';
  }
  
  /// Limpia toda la información de la venta
  static void clearAll() {
    total = 0;
    listProductsOrder.clear();
    clearShipping();
  }
}
