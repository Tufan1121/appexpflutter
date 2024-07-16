import 'dart:io';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class PdfViewerScreen extends HookWidget {
  final String fileName;
  final String search;
  final String url;

  const PdfViewerScreen({
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
        // await Future.delayed(Duration(seconds: 3));  // Añadimos el delay de 3 segundos
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
      try {
        Directory appDownloadsDir;
        if (Platform.isAndroid) {
          appDownloadsDir = Directory('/storage/emulated/0/Download/TufanApp');
        } else if (Platform.isIOS) {
          final downloadsDir = await getDownloadsDirectory();
          appDownloadsDir = Directory('${downloadsDir!.path}/TufanApp');
        } else {
          throw Exception('Unsupported platform');
        }

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
              content: Text(
                  'Error al descargar el PDF: $e. Intentando compartir...'),
            ),
          );
        }
      }
    }

    Future<void> sharePdf() async {
      try {
        // Descargar el PDF a una ubicación temporal
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName.pdf');
        await dio.download(url, tempFile.path);

        // Compartir el PDF
        await Share.shareXFiles([XFile(tempFile.path)],
            text: 'Compartiendo $fileName.pdf');
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al compartir el PDF: $e'),
            ),
          );
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Desactiva el ajuste del contenido al abrir el teclado o modal
      appBar: AppBar(
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
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: sharePdf,
          ),
        ],
      ),
      body: isUrlValid.value == null
          ? const Center(child: CircularProgressIndicator())
          : isUrlValid.value == true
              ? SfPdfViewer.network(
                  url,
                  key: pdfViewerKey.value,
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
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
    );
  }
}
