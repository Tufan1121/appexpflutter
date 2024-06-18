import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGallery(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia a cualquier color que desees
        ),
        backgroundColor: Colores.secondaryColor.withOpacity(0.78),
        title: Row(
          children: [
            Text(
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
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            key: Key(imageUrls.hashCode.toString()), // Agrega una Key única
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(
                    'https://tapetestufan.mx:446/imagen/${imageUrls[index]}'),
                initialScale: PhotoViewComputedScale.contained,
                minScale:
                    PhotoViewComputedScale.contained, // Nivel mínimo de zoom
                maxScale:
                    PhotoViewComputedScale.covered * 2, // Nivel máximo de zoom
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
              );
            },
            backgroundDecoration: const BoxDecoration(
              color: Colores.scaffoldBackgroundColor,
            ),
            pageController: PageController(initialPage: initialIndex),
          ),
        ],
      ),
    );
  }
}
