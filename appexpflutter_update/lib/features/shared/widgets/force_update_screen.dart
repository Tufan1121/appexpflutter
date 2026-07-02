import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/shared/services/version_gate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla bloqueante que obliga a actualizar. Se muestra en lugar de la app
/// cuando `checkForceUpdate()` detecta una versión por debajo del mínimo.
/// No hay forma de saltarla (PopScope sin pop y sin navegación).
class ForceUpdateScreen extends StatelessWidget {
  final ForceUpdateInfo info;

  const ForceUpdateScreen({super.key, required this.info});

  Future<void> _abrirActualizacion(BuildContext context) async {
    final url = info.updateUrl.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace de descarga')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mensaje = info.message.trim().isNotEmpty
        ? info.message.trim()
        : 'Hay una versión nueva disponible. Actualiza para seguir usando la '
            'aplicación.';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colores.gradientStart,
                Colores.gradientMiddle,
                Colores.gradientEnd,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.system_update,
                      color: Colors.white, size: 72),
                  const SizedBox(height: 24),
                  Text(
                    'Actualización requerida',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu versión: $kAppVersion'
                    '${info.latestVersion.isNotEmpty ? '  ·  Nueva: ${info.latestVersion}' : ''}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (info.updateUrl.trim().isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _abrirActualizacion(context),
                        icon: const Icon(Icons.download),
                        label: const Text('Actualizar ahora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colores.gradientEnd,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
