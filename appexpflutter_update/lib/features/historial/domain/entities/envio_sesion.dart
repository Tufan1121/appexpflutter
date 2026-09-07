/// Envío cotizado guardado con una sesión (partida ENVIO del detalle).
class EnvioSesion {
  /// Importe del envío (0 si la sesión no tiene envío).
  final double envio;

  /// Observación guardada con la partida: servicio y ruta
  /// "Origen: CP Ciudad -> Destino: CP Ciudad". Vacía en sesiones viejas.
  final String observa;

  const EnvioSesion({required this.envio, this.observa = ''});

  static const vacio = EnvioSesion(envio: 0);
}
