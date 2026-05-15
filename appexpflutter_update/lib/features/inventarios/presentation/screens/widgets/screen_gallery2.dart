import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventarios/domain/entities/producto_expo_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FullScreenGallery2 extends StatefulWidget {
  final ProductoExpoEntity producto;
  final int initialIndex;
  final List<String> imageUrls;

  const FullScreenGallery2({
    super.key,
    required this.initialIndex,
    required this.producto,
    required this.imageUrls,
  });

  @override
  State<FullScreenGallery2> createState() => _FullScreenGallery2State();
}

class _FullScreenGallery2State extends State<FullScreenGallery2> {
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
        Directory appDir;
        try {
          appDir = await getTemporaryDirectory();
        } catch (e) {
          final appDocs = await getApplicationDocumentsDirectory();
          appDir = appDocs;
        }

        final fileName = imageUrl.split('/').last;
        final fileNameWithExtension =
            fileName.contains('.') ? fileName : '$fileName.jpg';
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File(
            '${appDir.path}/share_${timestamp}_$fileNameWithExtension');

        final originalImageUrl =
            'https://tapetestufan.mx/imagen/$imageUrl';

        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'accessToken');

        final watermarkUrl = 'https://tapetestufan.mx:6007/add-watermark/';

        final response = await dio
            .post(
              watermarkUrl,
              queryParameters: {'image_url': originalImageUrl},
              options: Options(
                responseType: ResponseType.bytes,
                headers: {'Authorization': 'Bearer $token'},
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            )
            .timeout(
              const Duration(seconds: 35),
              onTimeout: () {
                throw Exception(
                    'Tiempo de espera agotado. Por favor intenta de nuevo.');
              },
            );

        if (response.data == null || (response.data as List<int>).isEmpty) {
          throw Exception('No se recibió la imagen del servidor');
        }

        await file.writeAsBytes(response.data);

        if (!await file.exists()) {
          throw Exception('Error al guardar la imagen temporalmente');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/jpeg')],
          text:
              'te comparto la imagen del producto ${imageUrl.split('/').first}',
        );

        try {
          await Future.delayed(const Duration(seconds: 2));
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Ignorar errores al limpiar
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
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
      resizeToAvoidBottomInset: false,
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
              onPressed: () => shareImage(widget.imageUrls[_currentIndex])),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  key: Key(widget.imageUrls.hashCode.toString()),
                  scrollPhysics: const BouncingScrollPhysics(),
                  itemCount: widget.imageUrls.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(
                        'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(widget.imageUrls[index])}',
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: widget.imageUrls[index],
                      ),
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
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Existencia: ${widget.producto.hm}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Almacen: ${widget.producto.almacen} - ${widget.producto.desalmacen}',
                  style: const TextStyle(fontSize: 16),
                ),
                if ((widget.producto.compos ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Composición: ${widget.producto.compos}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                if (widget.producto.lava1.trim().isNotEmpty ||
                    widget.producto.lava2.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Cuidados: ${[
                        widget.producto.lava1,
                        widget.producto.lava2
                      ].where((e) => e.trim().isNotEmpty).join(', ')}.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                if ((widget.producto.origen ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'País de origen: ${widget.producto.origen}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
