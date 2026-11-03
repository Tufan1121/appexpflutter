/// Avance de un guardado de varios pasos (encabezado → partidas → cierre).
///
/// Si la red o el servidor fallan a medio guardado y el usuario vuelve a dar
/// Guardar con la MISMA venta, se continúa donde se quedó en lugar de crear
/// otro encabezado (antes quedaban ventas, pedidos y cotizaciones duplicados).
/// Si la venta cambió (otra [firma]), se empieza de cero.
class GuardadoPendiente<T> {
  String? _firma;

  /// Encabezado ya creado en el backend (null si aún no se creó).
  T? encabezado;

  /// Partidas ya guardadas, en orden.
  int partidasGuardadas = 0;

  /// true cuando ya se guardaron todas las partidas (falta solo el cierre).
  bool partidasCompletas = false;

  /// Prepara un guardado: conserva el avance si es la misma venta.
  void iniciar(String firma) {
    if (firma == _firma) return;
    terminar();
    _firma = firma;
  }

  /// Olvida el avance (guardado terminado o venta descartada).
  void terminar() {
    _firma = null;
    encabezado = null;
    partidasGuardadas = 0;
    partidasCompletas = false;
  }
}

/// Firma de una venta: los datos del encabezado y sus partidas. Dos intentos
/// con la misma firma son la misma venta.
String firmaGuardado(Map<String, dynamic> data, Iterable<Object?> partidas) =>
    '$data|${partidas.join(';')}';
