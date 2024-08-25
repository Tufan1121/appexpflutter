import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class GaleriaDetailScreen extends StatefulWidget {
  final String producto;
  final int initialIndex;
  final List<String> imageUrls;
  final String? userName;

  const GaleriaDetailScreen({
    super.key,
    required this.initialIndex,
    required this.producto,
    required this.imageUrls,
    this.userName,
  });

  @override
  State<GaleriaDetailScreen> createState() => _GaleriaDetailScreenState();
}

class _GaleriaDetailScreenState extends State<GaleriaDetailScreen> {
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
            onPressed: () => shareImage(widget.imageUrls[_currentIndex]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PhotoViewGallery.builder(
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
                  ),
                  Positioned(
                    bottom: 50,
                    left: 300,
                    right: 15,
                    child: IconButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colores.secondaryColor),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0))),
                        ),
                        onPressed: () {},
                        icon: const FaIcon(FontAwesomeIcons.plus,
                            color: Colores.scaffoldBackgroundColor, size: 30)),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text('Medidas disponibles'),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 95,
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Text('Bienvenido ruben',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colores.primaryColor,
                            fontSize: 14,
                            shadows: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2.0, 5.0),
                              )
                            ],
                          ));
                    },
                  ),
                ),
              ],
            ),
            // Agrega más widgets aquí
          ],
        ),
      ),
    );
  }
}
