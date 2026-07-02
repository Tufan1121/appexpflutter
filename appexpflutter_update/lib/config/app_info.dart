import 'package:package_info_plus/package_info_plus.dart';

/// Versión de la app leída del propio APK/instalación. Fuente ÚNICA: el
/// `pubspec.yaml` (`version: 1.1.10+10110` → version "1.1.10", build 10110).
///
/// Se inicializa una sola vez en `main()` con [AppInfo.init] y luego se lee de
/// forma síncrona en el login y en el gate de actualización. Así solo hay que
/// subir el número en un lugar (el pubspec) en cada release.
class AppInfo {
  /// Nombre de versión (ej. "1.1.10").
  static String version = '';

  /// Build/versionCode (ej. 10110). 0 si aún no se inicializó.
  static int build = 0;

  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
      build = int.tryParse(info.buildNumber) ?? 0;
    } catch (_) {
      // Si falla, quedan los valores por defecto; el gate hace fail-open.
    }
  }
}
