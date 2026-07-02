import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/config/app_info.dart';

/// Nivel de actualización que decide el backend según la versión instalada.
enum UpdateKind {
  /// Al día: no se muestra nada.
  none,

  /// Hay versión nueva pero no es obligatoria → aviso suave y descartable.
  soft,

  /// La versión instalada quedó por debajo del mínimo → bloqueo total.
  force,
}

/// Resultado del chequeo de versión contra `/appVersion`.
class UpdateStatus {
  final UpdateKind kind;
  final String updateUrl;
  final String message;
  final String latestVersion;

  const UpdateStatus({
    required this.kind,
    this.updateUrl = '',
    this.message = '',
    this.latestVersion = '',
  });

  static const none = UpdateStatus(kind: UpdateKind.none);
}

/// Consulta `/appVersion` y decide el nivel de actualización.
///
/// - `build < min_build`   → [UpdateKind.force] (bloqueo).
/// - `build < latest_build`→ [UpdateKind.soft] (aviso descartable).
/// - en otro caso          → [UpdateKind.none].
///
/// Fail-open: si no se puede leer la versión instalada o el backend no
/// responde, devuelve [UpdateStatus.none] (nunca bloquea por un error).
Future<UpdateStatus> checkUpdate() async {
  if (AppInfo.build <= 0) return UpdateStatus.none;
  try {
    // Timeout corto: corre al arrancar; si el backend tarda, no retrasa el inicio.
    final res =
        await DioClient().get('/appVersion').timeout(const Duration(seconds: 6));
    final data = res.data;
    if (data is! Map) return UpdateStatus.none;

    final minBuild = (data['min_build'] as num?)?.toInt() ?? 0;
    final latestBuild = (data['latest_build'] as num?)?.toInt() ?? minBuild;
    final url = (data['update_url'] ?? '').toString();
    final msg = (data['message'] ?? '').toString();
    final latestVer = (data['latest_version'] ?? '').toString();

    if (AppInfo.build < minBuild) {
      return UpdateStatus(
        kind: UpdateKind.force,
        updateUrl: url,
        message: msg,
        latestVersion: latestVer,
      );
    }
    if (AppInfo.build < latestBuild) {
      return UpdateStatus(
        kind: UpdateKind.soft,
        updateUrl: url,
        message: msg,
        latestVersion: latestVer,
      );
    }
    return UpdateStatus.none;
  } catch (_) {
    return UpdateStatus.none; // fail-open
  }
}
