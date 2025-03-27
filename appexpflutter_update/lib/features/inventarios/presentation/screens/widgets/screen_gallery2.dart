import 'dart:io';

import 'package:appexpflutter_update/config/utils/utils.dart';
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
      try {
        final appDownloadsDir = await getTemporaryDirectory();
        final file =
            File('${appDownloadsDir.path}/${imageUrl.split('/').last}');
        await dio.download(
            'https://tapetestufan.mx:446/imagen/_web/$imageUrl', file.path);
        await Share.shareXFiles([XFile(file.path)],
            text:
                'te comparto la imagen del producto ${imageUrl.split('/').first}');
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al compartir la imagen: $e'),
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
                        'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(widget.imageUrls[index])}',
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
                  'Precio Normal: ${Utils.formatPrice(widget.producto.precio1.toDouble())}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Existencia: ${widget.producto.hm}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Almacen: ${widget.producto.almacen} - ${widget.producto.desalmacen}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
