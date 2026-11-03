import 'dart:io';
import 'dart:typed_data';
import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/enviar_pedido_whatsapp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
//  import 'package:path_provider/path_provider.dart';

class PdfViewerPedidoScreen extends HookWidget {
  final String fileName;
  final String search;
  final String url;
  final String userName;
  final String clientPhoneNumber;

  /// Expo de la cotización. Si viene, el WhatsApp sale del número de expo
  /// (backend /enviarCotizacionWhatsapp) y no se ofrece "Compartir", para que
  /// el vendedor no se quede con el contacto.
  final int? idExpo;

  const PdfViewerPedidoScreen({
    super.key,
    required this.fileName,
    required this.search,
    required this.url,
    required this.userName,
    required this.clientPhoneNumber,
    this.idExpo,
  });

  @override
  Widget build(BuildContext context) {
    final pdfViewerKey = useState(GlobalKey<SfPdfViewerState>());
    final isUrlValid = useState<bool?>(null);
    final isLoading = useState<bool>(true);
    final pdfBytes = useState<Uint8List?>(null);
    final enviandoWhatsApp = useState(false);
    final dio = useMemoized(() => Dio());
    final envioPorExpo = idExpo != null;

    useEffect(() {
      Future<void> checkUrlValidity() async {
        // Se descarga con Dio y se muestra desde memoria: SfPdfViewer.network
        // fallaba en Windows con un "Error" genérico aunque el PDF estuviera bien.
        // Un reintento por si el servidor aún no terminaba de escribirlo.
        for (var intento = 0; intento < 2; intento++) {
          await Future.delayed(Duration(seconds: intento == 0 ? 1 : 3));
          try {
            final response = await dio.get<List<int>>(
              url,
              queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
              options: Options(responseType: ResponseType.bytes),
            );
            final bytes = Uint8List.fromList(response.data ?? const []);
            // Un PDF válido empieza con "%PDF"
            if (bytes.length > 4 &&
                String.fromCharCodes(bytes.sublist(0, 4)) == '%PDF') {
              pdfBytes.value = bytes;
              break;
            }
          } catch (_) {}
        }
        isUrlValid.value = pdfBytes.value != null;
        isLoading.value = false;
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

    /// Envío desde el backend (WhatsApp de expo y/o correo). Sin teléfono o
    /// correo del cliente (o inválido) pide capturarlo y lo guarda.
    Future<void> enviarPorExpo(MediosEnvio medios) async {
      enviandoWhatsApp.value = true;
      try {
        await enviarPorMedios(
          dialogContext: context,
          messenger: ScaffoldMessenger.of(context),
          pedidos: fileName,
          idExpo: idExpo,
          medios: medios,
          cotizacion: true,
        );
      } finally {
        if (context.mounted) enviandoWhatsApp.value = false;
      }
    }

    // Recién terminada la cotización: preguntar cómo se le manda al cliente
    useEffect(() {
      if (envioPorExpo) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) return;
          final medios =
              await elegirMediosEnvio(context, 'Cotización $fileName generada');
          if (medios != null && context.mounted) enviarPorExpo(medios);
        });
      }
      return null;
    }, []);

    Future<void> sendToWhatsApp() async {
      try {
        final appDownloadsDir = await getTemporaryDirectory();
        final file = File('${appDownloadsDir.path}/$fileName.pdf');
        await dio.download(url, file.path);

        final whatsappUrl = Uri.parse(
            'whatsapp://send?phone=$clientPhoneNumber&text=Hola Soy $userName, te comparto el link de la $search $fileName. $url');
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

    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        if (context.mounted) {
          HomeRoute().push(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                HomeRoute().push(context);
              });
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colores.secondaryColor.withOpacity(0.78),
          title: AutoSizeText(
            '$search:  $fileName',
            maxLines: 1,
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
                    onPressed: envioPorExpo
                        ? () => enviarPorExpo((whatsapp: true, correo: false))
                        : sendToWhatsApp,
                  ),
            if (envioPorExpo && !enviandoWhatsApp.value)
              IconButton(
                tooltip: 'Enviar por correo',
                icon: const Icon(Icons.email_outlined),
                onPressed: () => enviarPorExpo((whatsapp: false, correo: true)),
              ),
          ],
        ),
        body: isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : isUrlValid.value == true
                ? SfPdfViewer.memory(
                    pdfBytes.value!,
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
