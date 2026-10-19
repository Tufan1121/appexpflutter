import 'dart:io';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/enviar_pedido_whatsapp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';

class PdfViewerScreen extends HookWidget {
  final String fileName;
  final String search;
  final String url;
  final String userName;
  final String clientPhoneNumber;

  /// Expo del pedido o cotización. Si viene, el WhatsApp sale del número de
  /// expo (backend /enviarPedidoWhatsapp o /enviarCotizacionWhatsapp) y no se
  /// ofrece "Compartir", para que el vendedor no se quede con el contacto.
  final int? idExpo;

  /// El documento es una cotización (si no, un pedido).
  final bool cotizacion;

  const PdfViewerScreen({
    super.key,
    required this.fileName,
    required this.search,
    required this.url,
    required this.userName,
    required this.clientPhoneNumber,
    this.idExpo,
    this.cotizacion = false,
  });

  @override
  Widget build(BuildContext context) {
    final pdfViewerKey = useState(GlobalKey<SfPdfViewerState>());
    final isUrlValid = useState<bool?>(null);
    final enviandoWhatsApp = useState(false);
    final dio = useMemoized(() => Dio());
    final envioPorExpo = idExpo != null;

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

    Future<void> enviarPorExpo() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enviar por WhatsApp'),
          content: Text(
              'Se enviará ${cotizacion ? 'la cotización' : 'el pedido'} $fileName al cliente desde el WhatsApp de la expo.'),
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

      enviandoWhatsApp.value = true;
      try {
        // Sin teléfono del cliente (o inválido) pide capturarlo y lo guarda
        await enviarPedidoWhatsApp(
          dialogContext: context,
          messenger: ScaffoldMessenger.of(context),
          pedidos: fileName,
          idExpo: idExpo,
          cotizacion: cotizacion,
        );
      } finally {
        if (context.mounted) enviandoWhatsApp.value = false;
      }
    }

    Future<void> sendToWhatsApp() async {
      try {
        final appDownloadsDir = await getTemporaryDirectory();
        final file = File('${appDownloadsDir.path}/$fileName.pdf');
        await dio.download(url, file.path);

        final whatsappUrl = Uri.parse(
            'whatsapp://send?phone=$clientPhoneNumber&text=Hola Soy $userName, te comparto el link del $search $fileName. $url');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir WhatsApp.'),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar a WhatsApp: $e'),
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
          if (!envioPorExpo)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: sharePdf,
            ),
          enviandoWhatsApp.value
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
                  onPressed: envioPorExpo ? enviarPorExpo : sendToWhatsApp,
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
