import 'package:appexpflutter_update/features/punto_venta/domain/entities/detalle_pedido_entity.dart';

class UtilsVenta {
  static double total = 0;
  static List<DetallePedidoEntity> listProductsOrder = [];

  /// Cantidad elegida por clave de producto.
  ///
  /// Se guarda por clave y no por posición porque la lista se reconstruye
  /// desde cero cada vez que el bloc emite ProductoLoading (al escanear otro
  /// producto) y porque al quitar un producto intermedio las posiciones se
  /// recorren: con índices, la cantidad y el precio terminaban aplicados al
  /// producto equivocado.
  static Map<String, int> cantidades = {};

  /// Precio elegido por clave de producto: 1 = precio de lista, 2 = precio expo.
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

  // Datos para el envío
  static double shippingCost = 0;
  static String shippingCarrier = '';
  static String shippingServiceDescription = '';
  static String shippingBreakdown = '';

  /// Ruta cotizada: "Origen: CP Ciudad, EDO -> Destino: CP Ciudad, EDO".
  static String shippingRuta = '';

  /// Observación de la partida ENVIO (servicio + origen/destino); el backend
  /// la guarda en pretikd.observa y va también en las observaciones del ticket.
  static String get shippingObserva {
    final partes = <String>[
      if (shippingServiceDescription.trim().isNotEmpty)
        shippingServiceDescription.trim(),
      if (shippingRuta.trim().isNotEmpty) shippingRuta.trim(),
    ];
    return partes.join(' | ');
  }

  static bool get hasShipping => shippingCost > 0;

  static double get totalWithShipping => total + shippingCost;

  /// Obtiene la descripción completa del envío incluyendo desglose
  static String get fullShippingDescription {
    if (shippingBreakdown.isEmpty) {
      return shippingServiceDescription;
    }
    return '$shippingServiceDescription\n$shippingBreakdown';
  }

  static void setShipping(double cost, String carrier, String serviceDescription,
      [String breakdown = '', String ruta = '']) {
    shippingCost = cost;
    shippingCarrier = carrier;
    shippingServiceDescription = serviceDescription;
    shippingBreakdown = breakdown;
    shippingRuta = ruta;
  }

  static void clearShipping() {
    shippingCost = 0;
    shippingCarrier = '';
    shippingServiceDescription = '';
    shippingBreakdown = '';
    shippingRuta = '';
  }

  static void clearAll() {
    total = 0;
    listProductsOrder = [];
    clearSelecciones();
    clearShipping();
  }
}
