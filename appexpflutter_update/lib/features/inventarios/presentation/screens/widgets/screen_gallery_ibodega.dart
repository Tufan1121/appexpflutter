import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class FullScreenGalleryIBodegas extends StatelessWidget {
  final ProductoEntity producto;
  final int initialIndex;
  final List<String> imageUrls;

  const FullScreenGalleryIBodegas({
    super.key,
    required this.initialIndex,
    required this.producto,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    final existencia = producto.bodega1 +
        producto.bodega2 +
        producto.bodega3 +
        producto.bodega4;

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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  key: Key(imageUrls.hashCode.toString()),
                  scrollPhysics: const BouncingScrollPhysics(),
                  itemCount: imageUrls.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(
                        'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(imageUrls[index])}',
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: imageUrls[index],
                      ),
                    );
                  },
                  backgroundDecoration: const BoxDecoration(
                    color: Colores.scaffoldBackgroundColor,
                  ),
                  pageController: PageController(initialPage: initialIndex),
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
                  'Precio Normal: ${Utils.formatPrice(producto.precio1.toDouble())}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Precio Expo: ${Utils.formatPrice(producto.precio2.toDouble())}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Precio Mayoreo: ${Utils.formatPrice(producto.precio3.toDouble())}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Existencia: ${existencia.toInt()}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                // Text(
                //   producto.desalmacen,
                //   style: TextStyle(fontSize: 16.0),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
