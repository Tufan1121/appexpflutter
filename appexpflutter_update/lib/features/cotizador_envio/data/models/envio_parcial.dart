/// Envíos de un pedido / cotización / ticket: puede haber varias partidas
/// ENVIO (p. ej. paquete para el tapete chico y Big Ticket para el grande),
/// cada una con los tapetes que esa paquetería cotizó. Misma regla que
/// cotizaciones.html en galería.
///
/// Los tapetes que ningún envío cubre llevan la leyenda [leyendaSinEnvio] al
/// inicio de su observación; se quita al cubrirlos o al quitar los envíos.
class EnvioParcial {
  EnvioParcial._();

  static const leyendaSinEnvio = 'No se cotizó el envío';

  /// Largo máximo de la observación de una partida (mismo que el TextField).
  static const maxObserva = 250;

  static bool tieneLeyenda(String observa) =>
      observa.trim().startsWith(leyendaSinEnvio);

  /// Observación sin la leyenda (conserva lo que haya escrito el vendedor).
  static String quitarLeyenda(String observa) {
    final obs = observa.trim();
    if (!obs.startsWith(leyendaSinEnvio)) return obs;
    return obs
        .substring(leyendaSinEnvio.length)
        .replaceFirst(RegExp(r'^\s*·\s*'), '')
        .trim();
  }

  /// Observación con la leyenda al inicio, sin duplicarla.
  static String ponerLeyenda(String observa) {
    final obs = quitarLeyenda(observa);
    final texto = obs.isEmpty ? leyendaSinEnvio : '$leyendaSinEnvio · $obs';
    return texto.length > maxObserva ? texto.substring(0, maxObserva) : texto;
  }

  /// Mensaje del aviso cuando se quitan los envíos por un cambio en las partidas.
  static String motivoQuitado(String nombre, CambioPartida cambio) {
    switch (cambio) {
      case CambioPartida.nueva:
        return 'Se quita el envío cotizado porque se está agregando otra partida ("$nombre").';
      case CambioPartida.cantidad:
        return 'Se quita el envío cotizado porque cambió la cantidad de "$nombre".';
      case CambioPartida.eliminada:
        return 'Se quita el envío cotizado porque se eliminó la partida "$nombre".';
    }
  }
}

enum CambioPartida { nueva, cantidad, eliminada }

/// Una partida ENVIO: lo que se eligió en el cotizador.
class EnvioAgregado {
  EnvioAgregado({
    required this.importe,
    required this.carrier,
    required this.servicio,
    this.ruta = '',
    this.cubre,
    this.parcial = false,
  });

  final double importe;

  /// Paquetería (p. ej. "Paquetexpress").
  final String carrier;

  /// Modo, guías y sucursal de ocurre.
  final String servicio;

  /// "Origen: CP Ciudad, EDO -> Destino: CP Ciudad, EDO".
  final String ruta;

  /// Tapetes que cubre (clave → nombre para el PDF). null = cobertura
  /// desconocida (envío restaurado de una sesión guardada).
  final Map<String, String>? cubre;

  /// No cubre todos los tapetes del pedido: la observación dice cuáles sí.
  final bool parcial;

  /// Observación de la partida ENVIO (sale en el PDF y el ticket). La
  /// cobertura va primero y se corta a 250 caracteres (tamaño de la columna).
  String get observa {
    final texto = [
      if (parcial && cubre != null) 'Cubre: ${cubre!.values.join(', ')}',
      servicio.trim(),
      ruta.trim(),
    ].where((s) => s.isNotEmpty).join(' | ');
    return texto.length > EnvioParcial.maxObserva
        ? texto.substring(0, EnvioParcial.maxObserva)
        : texto;
  }
}

/// Lista de envíos agregados. Cada UtilsVenta (ventas y punto de venta) tiene
/// la suya; las leyendas de las partidas las maneja UtilsVenta.
class EnviosCotizados {
  final List<EnvioAgregado> lista = [];

  double get total => lista.fold(0.0, (s, e) => s + e.importe);

  bool get isEmpty => lista.isEmpty;

  /// Claves que cubre algún envío (unión).
  Set<String> get cubiertas => {
        for (final e in lista)
          if (e.cubre != null) ...e.cubre!.keys,
      };

  String get carriers => lista.map((e) => e.carrier).join(' + ');

  /// Descripción de servicio(s) para pantalla.
  String get descripcion => lista.length == 1
      ? lista.first.servicio
      : lista.map((e) => '${e.carrier}: ${e.servicio}').join(' | ');

  String get ruta => lista.isEmpty ? '' : lista.first.ruta;

  /// Agrega un envío. Los que se traslapan con él (cubren alguno de sus
  /// tapetes) o cuya cobertura se desconoce se reemplazan.
  void agregar(EnvioAgregado envio) {
    final nuevos = envio.cubre?.keys.toSet();
    lista.removeWhere((e) =>
        e.cubre == null ||
        nuevos == null ||
        e.cubre!.keys.any(nuevos.contains));
    lista.add(envio);
  }

  void clear() => lista.clear();
}

/// Lo que cubren los envíos agregados y lo que falta (clave → nombre), para
/// el aviso del cotizador.
class CoberturaEnvios {
  const CoberturaEnvios({required this.envios, required this.faltan});

  final List<EnvioAgregado> envios;
  final Map<String, String> faltan;
}
