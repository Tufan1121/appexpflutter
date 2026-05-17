import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:api_client/api_client.dart' show Environment;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

/// Flujo "Ver en mi espacio": el usuario toma/elige una foto de su espacio,
/// se combina con el tapete seleccionado vía el endpoint `/visualizarTapete`
/// (replicado en `mainPromos.py` desde `mainWeb.py`) y se muestra el
/// resultado generado por Gemini.
///
/// Las medidas (`anchoM` / `largoM`) vienen de la variante seleccionada del
/// tapete (en metros) y se mandan al backend en cm.
class VisualizarTapete {
  static final ImagePicker _picker = ImagePicker();

  /// Punto de entrada. Muestra el selector de fuente (cámara/galería),
  /// el loading y finalmente el resultado.
  static Future<void> iniciar(
    BuildContext context, {
    required String tapeteUrl,
    required double anchoM,
    required double largoM,
    required String titulo,
  }) async {
    if (tapeteUrl.trim().isEmpty) {
      _toast(context, 'Este tapete no tiene imagen', error: true);
      return;
    }
    if (anchoM <= 0 || largoM <= 0) {
      _toast(context, 'El tapete no tiene medidas válidas', error: true);
      return;
    }

    final source = await _elegirFuente(context);
    if (source == null) return;

    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
    } catch (e) {
      if (context.mounted) {
        _toast(context, 'No se pudo abrir la cámara/galería: $e',
            error: true);
      }
      return;
    }
    if (picked == null) return; // canceló

    if (!context.mounted) return;
    // El loading se cierra usando SU PROPIO contexto (loadingCtx), nunca el
    // de la card: así es imposible popear por error la pantalla de búsqueda
    // y terminar en el home. PopScope(canPop:false) evita que el botón atrás
    // del sistema descarte el loading durante la generación (15-150s) y deje
    // un pop "huérfano" que después sacaría de la pantalla de búsqueda.
    BuildContext? loadingCtx;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        loadingCtx = ctx;
        return PopScope(
          canPop: false,
          child: _loadingDialog(ctx, titulo),
        );
      },
    );

    void cerrarLoading() {
      if (loadingCtx != null && loadingCtx!.mounted) {
        Navigator.of(loadingCtx!).pop();
        loadingCtx = null;
      }
    }

    try {
      final bytes = await _llamarEndpoint(
        espacioPath: picked.path,
        tapeteUrl: tapeteUrl,
        anchoCm: anchoM * 100,
        largoCm: largoM * 100,
      );
      cerrarLoading();
      if (context.mounted) {
        _mostrarResultado(context, bytes, titulo);
      }
    } catch (e) {
      cerrarLoading();
      if (context.mounted) {
        _toast(context, 'No se pudo generar: ${_msgError(e)}', error: true);
      }
    }
  }

  // ─────────────────────────── red ──────────────────────────────────────

  static Future<Uint8List> _llamarEndpoint({
    required String espacioPath,
    required String tapeteUrl,
    required double anchoCm,
    required double largoCm,
  }) async {
    final token =
        await const FlutterSecureStorage().read(key: 'accessToken');
    // Dio dedicado: la generación con Gemini tarda 15-30s, el DioClient
    // global tiene receiveTimeout de 15s y reventaría.
    final dio = Dio(BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 150),
    ));
    // Dio NO infiere el MIME por el nombre de archivo: sin `contentType`
    // explícito sube la foto como `application/octet-stream`, y el backend
    // reenvía ese tipo a Gemini, que lo rechaza con HTTP 400
    // ("Unsupported MIME type: application/octet-stream").
    final ext = espacioPath.toLowerCase();
    final subtype = ext.endsWith('.png')
        ? 'png'
        : ext.endsWith('.webp')
            ? 'webp'
            : 'jpeg';
    final form = FormData.fromMap({
      'espacio': await MultipartFile.fromFile(
        espacioPath,
        filename: 'espacio.$subtype',
        contentType: DioMediaType('image', subtype),
      ),
      'tapete_url': tapeteUrl,
      'ancho_cm': anchoCm.toStringAsFixed(0),
      'largo_cm': largoCm.toStringAsFixed(0),
      'orientacion': 'auto',
    });
    final resp = await dio.post(
      '/visualizarTapete',
      data: form,
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
    final data = resp.data;
    final b64 = (data is Map) ? data['image'] as String? : null;
    if (b64 == null || b64.isEmpty) {
      throw Exception('El servidor no devolvió imagen');
    }
    return base64Decode(b64);
  }

  static String _msgError(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map && d['detail'] != null) return d['detail'].toString();
      return e.message ?? 'Error de red';
    }
    return e.toString();
  }

  // ─────────────────────────── UI ───────────────────────────────────────

  static Future<ImageSource?> _elegirFuente(BuildContext context) {
    final theme = Theme.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Foto de tu espacio',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _loadingDialog(BuildContext context, String titulo) {
    final theme = Theme.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 18),
            Text(
              'Generando visualización…',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Esto tarda 15-30 segundos',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  static void _mostrarResultado(
      BuildContext context, Uint8List bytes, String titulo) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: MediaQuery.of(ctx).size.height * 0.6,
                    child: PhotoView(
                      imageProvider: MemoryImage(bytes),
                      backgroundDecoration:
                          BoxDecoration(color: theme.colorScheme.surface),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Descargar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                        onPressed: () => _descargar(ctx, bytes),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _compartir(ctx, bytes),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Guarda la imagen generada en la carpeta de descargas pública.
  /// Misma convención que los visores de PDF del proyecto:
  /// `Download/TufanApp` en Android, `getDownloadsDirectory()/TufanApp`
  /// en iOS/escritorio.
  static Future<void> _descargar(
      BuildContext context, Uint8List bytes) async {
    try {
      Directory destDir;
      if (Platform.isAndroid) {
        destDir = Directory('/storage/emulated/0/Download/TufanApp');
      } else {
        final downloads = await getDownloadsDirectory();
        final base =
            downloads ?? await getApplicationDocumentsDirectory();
        destDir = Directory('${base.path}/TufanApp');
      }
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }
      final file = File(
          '${destDir.path}/visualizacion_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      if (context.mounted) {
        _toast(context, 'Imagen guardada en ${file.path}');
      }
    } catch (e) {
      if (context.mounted) {
        _toast(context, 'Error al descargar: $e', error: true);
      }
    }
  }

  static Future<void> _compartir(
      BuildContext context, Uint8List bytes) async {
    try {
      Directory dir;
      try {
        dir = await getTemporaryDirectory();
      } catch (_) {
        dir = await getApplicationDocumentsDirectory();
      }
      final file = File(
          '${dir.path}/visualizacion_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Visualización de tu espacio con tapete Tufan',
      );
      try {
        await Future.delayed(const Duration(seconds: 2));
        if (await file.exists()) await file.delete();
      } catch (_) {}
    } catch (e) {
      if (context.mounted) {
        _toast(context, 'Error al compartir: $e', error: true);
      }
    }
  }

  static void _toast(BuildContext context, String msg,
      {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
