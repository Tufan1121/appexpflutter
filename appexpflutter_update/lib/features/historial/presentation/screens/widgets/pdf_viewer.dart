import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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

    return Scaffold(
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
      ),
      body: isUrlValid.value == null
          ? const Center(child: CircularProgressIndicator())
          : isUrlValid.value == true
              ? SfPdfViewer.network(
                  url,
                  key: pdfViewerKey.value,
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
