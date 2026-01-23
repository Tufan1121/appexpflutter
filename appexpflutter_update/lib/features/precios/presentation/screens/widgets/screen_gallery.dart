import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String medidas;

  const FullScreenGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    required this.medidas,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  final dio = Dio();
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> shareImage(String imageUrl) async {
      // Mostrar indicador de carga
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Preparando imagen con marca de agua...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      try {
        // Intentar obtener directorio temporal, con fallback a documents
        Directory appDir;
        try {
          appDir = await getTemporaryDirectory();
        } catch (e) {
          final appDocs = await getApplicationDocumentsDirectory();
          appDir = appDocs;
        }
        
        // Asegurar que el archivo tenga una extensión válida
        final fileName = imageUrl.split('/').last;
        final fileNameWithExtension = fileName.contains('.') 
            ? fileName 
            : '$fileName.jpg';
        
        // Crear archivo con timestamp para evitar conflictos
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${appDir.path}/share_$timestamp\_$fileNameWithExtension');
        
        // Construir la URL original de la imagen
        final originalImageUrl = 'https://tapetestufan.mx:446/imagen/_web/$imageUrl';
        
        // Obtener token de autenticación
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'accessToken');
        
        // Endpoint de marca de agua - requiere POST
        final watermarkUrl = 'https://tapetestufan.mx:6002/add-watermark/';
        
        // Hacer POST request con autenticación y timeout extendido
        final response = await dio.post(
          watermarkUrl,
          queryParameters: {'image_url': originalImageUrl},
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'Authorization': 'Bearer $token'},
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        ).timeout(
          const Duration(seconds: 35),
          onTimeout: () {
            throw Exception('Tiempo de espera agotado. Por favor intenta de nuevo.');
          },
        );
        
        // Verificar que la respuesta tenga datos
        if (response.data == null || (response.data as List<int>).isEmpty) {
          throw Exception('No se recibió la imagen del servidor');
        }
        
        // Guardar imagen con marca de agua
        await file.writeAsBytes(response.data);
        
        // Verificar que el archivo se escribió correctamente
        if (!await file.exists()) {
          throw Exception('Error al guardar la imagen temporalmente');
        }
        
        // Ocultar el indicador de carga
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        
        // Compartir con MIME type explícito para Android
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/jpeg')],
          text: 'Te comparto la imagen del producto ${imageUrl.split('/').first} medidas: ${widget.medidas}',
        );
        
        // Limpiar archivo temporal después de compartir
        try {
          await Future.delayed(const Duration(seconds: 2));
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Ignorar errores al limpiar
        }
      } catch (e) {
        // Ocultar indicador de carga
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        
        // Mostrar error específico
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al compartir: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () => shareImage(imageUrl),
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colores.secondaryColor.withOpacity(0.78),
        title: Text(
          'Galería',
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
            icon: const Icon(Icons.share),
            onPressed: () => shareImage(widget.imageUrls[_currentIndex]),
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            key: Key(widget.imageUrls.hashCode
                .toString()), // Key única para la galería
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: widget.imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(
                  'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(widget.imageUrls[index])}',
                ),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.imageUrls[index]), // Tag único para cada imagen
              );
            },
            backgroundDecoration: const BoxDecoration(
              color: Colores.scaffoldBackgroundColor,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
