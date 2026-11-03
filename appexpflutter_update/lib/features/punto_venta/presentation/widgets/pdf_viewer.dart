import 'dart:io';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/enviar_pedido_whatsapp.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends HookWidget {
  final String fileName;
  final String url;
  final String? userName;
  final String? clientPhoneNumber;

  const PdfViewerScreen({
    super.key,
    required this.fileName,
    required this.url,
    this.userName,
    this.clientPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final pdfViewerKey = useState(GlobalKey<SfPdfViewerState>());
    final isUrlValid = useState<bool?>(null);
    final enviando = useState(false);
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

    /// El ticket sale por WhatsApp desde el número central (backend), ya no
    /// desde el del vendedor; si el ticket no tiene teléfono se pide capturarlo.
    Future<void> enviarTicket() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enviar por WhatsApp'),
          content: Text(
              'Se enviará el ticket $fileName al cliente desde el WhatsApp de Tapetes Tufán.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enviar'),
            ),
          ],
        ),
      );
      if (confirmar != true || !context.mounted) return;

      enviando.value = true;
      try {
        await enviarPedidoWhatsApp(
          dialogContext: context,
          messenger: ScaffoldMessenger.of(context),
          pedidos: fileName,
          ticket: true,
        );
      } finally {
        if (context.mounted) enviando.value = false;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Desactiva el ajuste del contenido al abrir el teclado o modal
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colores.secondaryColor.withOpacity(0.78),
        title: AutoSizeText(
          'Ticket:  $fileName',
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
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: downloadPdf,
          ),
          enviando.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp),
                  onPressed: enviarTicket,
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
