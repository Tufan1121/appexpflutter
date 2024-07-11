import 'dart:io';
import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
//  import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerPedidoScreen extends HookWidget {
  final String fileName;
  final String search;
  final String url;

  const PdfViewerPedidoScreen({
    super.key,
    required this.fileName,
    required this.search,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final pdfViewerKey = useState(GlobalKey<SfPdfViewerState>());
    final isUrlValid = useState<bool?>(null);
    final dio = useMemoized(() => Dio());

    useEffect(() {
      Future<void> checkUrlValidity() async {
        try {
          final response = await dio.head(url);
          isUrlValid.value = response.statusCode == 200;
        } catch (e) {
          isUrlValid.value = false;
        }
      }

      checkUrlValidity();
      return null;
    }, [url]);

    Future<void> downloadPdf() async {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          final appDownloadsDir =
              Directory('/storage/emulated/0/Download/TufanApp');
          if (!await appDownloadsDir.exists()) {
            await appDownloadsDir.create(recursive: true);
          }
          final file = File('${appDownloadsDir.path}/$fileName.pdf');
          await dio.download(url, file.path);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF descargado en ${file.path}'),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al descargar el PDF: $e'),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso de almacenamiento denegado'),
            ),
          );
        }
      }
    }

    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        HomeRoute().push(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                HomeRoute().push(context);
              });
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colores.secondaryColor.withOpacity(0.78),
          title: Text(
            '$search:  $fileName',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colores.scaffoldBackgroundColor,
              shadows: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2.0, 5.0),
                )
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: downloadPdf,
            ),
          ],
        ),
        body: isUrlValid.value == null
            ? const Center(child: CircularProgressIndicator())
            : isUrlValid.value == true
                ? SfPdfViewer.network(
                    url,
                    key: pdfViewerKey.value,
                    onDocumentLoadFailed:
                        (PdfDocumentLoadFailedDetails details) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content:
                              Text('Error al cargar el PDF: ${details.error}'),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No se pudo acceder al PDF. Verifique la URL e inténtelo nuevamente.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
      ),
    );
  }
}
