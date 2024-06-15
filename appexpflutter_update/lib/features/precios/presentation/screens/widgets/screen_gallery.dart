import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
                'Galeria',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colores.scaffoldBackgroundColor,
                    shadows: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2.0, 5.0),
                      )
                    ]),
              )
            ],
          )),
      body: PhotoViewGallery.builder(
        pageController: PageController(initialPage: initialIndex),
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
                'https://tapetestufan.mx:446/imagen/${imageUrls[index]}'),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
          );
        },
      ),
    );
  }
}
