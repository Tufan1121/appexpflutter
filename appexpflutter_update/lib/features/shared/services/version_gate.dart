import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/config/app_info.dart';

/// Datos para forzar actualización cuando la versión instalada quedó por debajo
/// del mínimo soportado que reporta el backend en `/appVersion`.
class ForceUpdateInfo {
  final String updateUrl;
  final String message;
  final String latestVersion;

  const ForceUpdateInfo({
    required this.updateUrl,
    required this.message,
    required this.latestVersion,
  });
}

/// Consulta `/appVersion` y decide si hay que forzar actualización.
///
/// Devuelve `null` si la app está al día **o** si no se pudo verificar
/// (fail-open a propósito: un problema de red o del backend nunca debe dejar
/// la app inutilizable). Solo devuelve datos cuando `kAppBuild < min_build`.
Future<ForceUpdateInfo?> checkForceUpdate() async {
  // Si no se pudo leer la versión instalada, no bloquear (fail-open).
  if (AppInfo.build <= 0) return null;
  try {
    // Timeout corto: el gate corre al arrancar; si el backend tarda, no debe
    // retrasar el inicio (se resuelve como "al día" por el catch de abajo).
    final res =
        await DioClient().get('/appVersion').timeout(const Duration(seconds: 6));
    final data = res.data;
    if (data is! Map) return null;

    final minBuild = (data['min_build'] as num?)?.toInt() ?? 0;
    if (AppInfo.build >= minBuild) return null; // al día

    return ForceUpdateInfo(
      updateUrl: (data['update_url'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      latestVersion: (data['latest_version'] ?? '').toString(),
    );
  } catch (_) {
    return null; // fail-open: no bloquear si no se puede verificar
  }
}
