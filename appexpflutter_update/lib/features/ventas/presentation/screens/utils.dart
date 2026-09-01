import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';

class UtilsVenta {
  /// Total de productos (sin envío)
  static double total = 0;
  
  /// Lista de productos en el pedido
  static List<DetallePedidoEntity> listProductsOrder = [];
  
  /// Cantidad elegida por clave de producto.
  ///
  /// Se guarda por clave y no por posición porque la lista se reconstruye
  /// desde cero cada vez que el bloc emite ProductoLoading (al escanear otro
  /// producto) y porque al quitar un producto intermedio las posiciones se
  /// recorren: con índices, la cantidad y el precio terminaban aplicados al
  /// producto equivocado.
  static Map<String, int> cantidades = {};

  /// Precio elegido por clave: 1 = lista, 2 = expo, 3 = mayoreo/manual.
  static Map<String, int> preciosSeleccionados = {};

  static int cantidadDe(String clave) {
    final cantidad = cantidades[clave] ?? 1;
    return cantidad < 1 ? 1 : cantidad;
  }

  static int precioSeleccionadoDe(String clave) =>
      preciosSeleccionados[clave] ?? 1;

  static void setCantidad(String clave, int cantidad) {
    cantidades[clave] = cantidad < 1 ? 1 : cantidad;
  }

  static void setPrecioSeleccionado(String clave, int opcion) {
    preciosSeleccionados[clave] = opcion;
  }

  /// Observaciones opcionales por partida, indexadas por clave. Viajan en la
  /// columna `observa` del detalle en backend.
  static Map<String, String> observacionesPorClave = {};

  static String observaDe(String clave) => observacionesPorClave[clave] ?? '';

  static void setObserva(String clave, String texto) {
    final limpio = texto.trim();
    if (limpio.isEmpty) {
      observacionesPorClave.remove(clave);
    } else {
      observacionesPorClave[clave] = limpio;
    }
  }

  /// Descarta la selección de un producto que se quitó del pedido.
  static void olvidar(String clave) {
    cantidades.remove(clave);
    preciosSeleccionados.remove(clave);
    descuentosPorClave.remove(clave);
    observacionesPorClave.remove(clave);
  }

  static void clearSelecciones() {
    cantidades.clear();
    preciosSeleccionados.clear();
    observacionesPorClave.clear();
    clearDescuentos();
  }

  // ---------------------------------------------------------------------------
  // Descuentos autorizados
  // ---------------------------------------------------------------------------

  /// Descuento general autorizado, en porcentaje (0–100). Se aplica a todas
  /// las partidas por igual (prorrateo automático).
  static double descuentoGeneral = 0;

  /// Descuento por partida, en porcentaje (0–100), indexado por clave.
  static Map<String, double> descuentosPorClave = {};

  static double descuentoDe(String clave) => descuentosPorClave[clave] ?? 0;

  static void setDescuento(String clave, double pct) {
    if (pct <= 0) {
      descuentosPorClave.remove(clave);
    } else {
      descuentosPorClave[clave] = pct > 100 ? 100 : pct;
    }
  }

  static bool get hayDescuento =>
      descuentoGeneral > 0 || descuentosPorClave.isNotEmpty;

  /// Precio unitario final: primero el descuento de la partida y sobre ese
  /// resultado el descuento general (son acumulables, no se suman los %).
  static double aplicarDescuentos(String clave, double precioBase) {
    final conPartida = precioBase * (1 - descuentoDe(clave) / 100);
    return conPartida * (1 - descuentoGeneral / 100);
  }

  static void clearDescuentos() {
    descuentoGeneral = 0;
    descuentosPorClave.clear();
  }

  /// Costo del envío seleccionado (0 si no hay envío)
  static double shippingCost = 0;
  
  /// Nombre del carrier seleccionado (vacío si no hay envío)
  static String shippingCarrier = '';
  
  /// Descripción del servicio de envío (vacío si no hay envío)
  static String shippingServiceDescription = '';
  
  /// Desglose de costos por producto (para observaciones)
  static String shippingBreakdown = '';
  
  /// Indica si se ha seleccionado un envío
  static bool get hasShipping => shippingCost > 0;
  
  /// Total incluyendo envío
  static double get totalWithShipping => total + shippingCost;
  
  /// Obtiene la descripción completa del envío incluyendo desglose
  static String get fullShippingDescription {
    if (shippingBreakdown.isEmpty) {
      return shippingServiceDescription;
    }
    return '$shippingServiceDescription\\n$shippingBreakdown';
  }
  
  /// Establece el envío seleccionado
  static void setShipping({
    required double cost,
    required String carrier,
    required String serviceDescription,
    String breakdown = '',
  }) {
    shippingCost = cost;
    shippingCarrier = carrier;
    shippingServiceDescription = serviceDescription;
    shippingBreakdown = breakdown;
  }
  
  /// Limpia la información del envío
  static void clearShipping() {
    shippingCost = 0;
    shippingCarrier = '';
    shippingServiceDescription = '';
    shippingBreakdown = '';
  }
  
  /// Limpia toda la información de la venta
  static void clearAll() {
    total = 0;
    listProductsOrder.clear();
    clearSelecciones();
    clearShipping();
  }
}

