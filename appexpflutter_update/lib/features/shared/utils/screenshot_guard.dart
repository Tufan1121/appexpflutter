import 'package:flutter/widgets.dart';
import 'package:no_screenshot/no_screenshot.dart';

/// Bloqueo de capturas de pantalla (FLAG_SECURE en Android, capa segura en
/// iOS) para proteger las imágenes de los tapetes.
///
/// Usa conteo de referencias porque hay pantallas protegidas anidadas
/// (p. ej. galería → detalle de galería): la captura se vuelve a permitir
/// solo cuando se cierra la ÚLTIMA pantalla protegida, no la primera.
class ScreenshotGuard {
  ScreenshotGuard._();

  static final _noScreenshot = NoScreenshot.instance;
  static int _count = 0;

  /// Bloquea capturas. Llamar al entrar a una pantalla con imágenes.
  static Future<void> block() async {
    _count++;
    if (_count == 1) {
      await _noScreenshot.screenshotOff();
    }
  }

  /// Libera el bloqueo. Llamar al salir de la pantalla (dispose).
  static Future<void> unblock() async {
    if (_count > 0) _count--;
    if (_count == 0) {
      await _noScreenshot.screenshotOn();
    }
  }
}

/// Mixin para `State`s que deben bloquear capturas mientras están montados.
///
/// ```dart
/// class _MiPantallaState extends State<MiPantalla> with ScreenshotBlock {
/// ```
mixin ScreenshotBlock<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    ScreenshotGuard.block();
  }

  @override
  void dispose() {
    ScreenshotGuard.unblock();
    super.dispose();
  }
}
