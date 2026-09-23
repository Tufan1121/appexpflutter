import 'package:appexpflutter_update/features/cotizador_envio/data/models/envio_parcial.dart';
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

  // ---------------------------------------------------------------------------
  // Envío: una o varias partidas ENVIO (p. ej. paquete para un tapete y Big
  // Ticket para otro), cada una con los tapetes que cubre.
  // ---------------------------------------------------------------------------

  static final EnviosCotizados envios = EnviosCotizados();

  /// Suma de los envíos (0 si no hay envío).
  static double get shippingCost => envios.total;

  /// Paquetería(s) de los envíos.
  static String get shippingCarrier => envios.carriers;

  /// Servicio(s) de los envíos.
  static String get shippingServiceDescription => envios.descripcion;

  /// Ruta cotizada: "Origen: CP Ciudad, EDO -> Destino: CP Ciudad, EDO".
  static String get shippingRuta => envios.ruta;

  /// Observación de la única partida ENVIO (`envio_observa`); el importe
  /// (`envio`) es [shippingCost], la suma de todos los envíos. Una sola
  /// partida porque al pasar el pedido a ticket solo puede ir una de envío.
  static String get shippingObserva => envios.observaAgrupada;

  /// Indica si se ha seleccionado un envío
  static bool get hasShipping => shippingCost > 0;

  /// Total incluyendo envío
  static double get totalWithShipping => total + shippingCost;

  /// Envío restaurado de una sesión guardada: un solo envío, con cobertura
  /// desconocida (se reemplaza al agregar otro).
  static void setShipping({
    required double cost,
    required String carrier,
    required String serviceDescription,
    String ruta = '',
  }) {
    clearShipping();
    envios.agregar(EnvioAgregado(
      importe: cost,
      carrier: carrier,
      servicio: serviceDescription,
      ruta: ruta,
    ));
  }

  /// Agrega el envío elegido en el cotizador. [partidas]: todas las partidas
  /// del pedido (clave → nombre). La leyenda "No se cotizó el envío" queda
  /// solo en las que ningún envío cubre.
  static void agregarEnvio(EnvioAgregado envio, Map<String, String> partidas) {
    envios.agregar(envio);
    final faltan = coberturaEnvios(partidas).faltan;
    for (final clave in partidas.keys) {
      final obs = observaDe(clave);
      setObserva(
          clave,
          faltan.containsKey(clave)
              ? EnvioParcial.ponerLeyenda(obs)
              : EnvioParcial.quitarLeyenda(obs));
    }
  }

  /// Envíos agregados y partidas que ninguno cubre.
  static CoberturaEnvios coberturaEnvios(Map<String, String> partidas) {
    final cubiertas = envios.cubiertas;
    return CoberturaEnvios(
      envios: List.unmodifiable(envios.lista),
      faltan: {
        for (final p in partidas.entries)
          if (!cubiertas.contains(p.key)) p.key: p.value,
      },
    );
  }

  /// Limpia la información del envío
  static void clearShipping() {
    envios.clear();
    // Sin envío ya no aplica la leyenda "No se cotizó el envío".
    quitarLeyendasSinEnvio();
  }

  /// Aviso pendiente porque se quitaron los envíos al cambiar las partidas;
  /// la lista lo muestra (diálogo) en su siguiente build.
  static String? avisoEnvioQuitado;

  /// La partida quedó fuera de los envíos cotizados (lleva la leyenda).
  static bool sinEnvio(String clave) =>
      EnvioParcial.tieneLeyenda(observaDe(clave));

  static void quitarLeyendasSinEnvio() {
    for (final clave in observacionesPorClave.keys.toList()) {
      setObserva(clave, EnvioParcial.quitarLeyenda(observaDe(clave)));
    }
  }

  /// Cambió lo que se embarca (se agregó, eliminó o cambió de cantidad un
  /// tapete): los envíos ya no corresponden, así que se quitan y queda el
  /// aviso pendiente. Una partida con "No se cotizó el envío" ([clave]) no
  /// estaba incluida y no los afecta. Se llama antes de olvidar la partida.
  /// Devuelve true si quitó los envíos.
  static bool quitarEnvioPorCambio(String nombre, CambioPartida cambio,
      {String? clave}) {
    if (!hasShipping) return false;
    if (clave != null && sinEnvio(clave)) return false;
    clearShipping();
    avisoEnvioQuitado = EnvioParcial.motivoQuitado(nombre.trim(), cambio);
    return true;
  }

  /// Limpia toda la información de la venta
  static void clearAll() {
    total = 0;
    listProductsOrder.clear();
    clearSelecciones();
    clearShipping();
  }
}

