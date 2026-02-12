import 'dart:io';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FullScreenGalleryIBodegas extends StatefulWidget {
  final ProductoEntity producto;
  final int initialIndex;
  final List<String> imageUrls;
  final String? userName;
  final String? clientPhoneNumber;

  const FullScreenGalleryIBodegas({
    super.key,
    required this.initialIndex,
    required this.producto,
    required this.imageUrls,
    this.userName,
    this.clientPhoneNumber,
  });

  @override
  State<FullScreenGalleryIBodegas> createState() =>
      _FullScreenGalleryIBodegasState();
}

class _FullScreenGalleryIBodegasState extends State<FullScreenGalleryIBodegas> {
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
    final existencia = widget.producto.bodega1 +
        widget.producto.bodega2 +
        widget.producto.bodega3 +
        widget.producto.bodega4;

    // Future<void> downloadImage(String imageUrl, String fileName) async {
    //   try {
    //     final status = await Permission.storage.request();
    //     if (status.isGranted) {
    //       final appDownloadsDir =
    //           Platform.isAndroid
    //               ? Directory('/storage/emulated/0/Download/TufanApp')
    //               : await getApplicationDocumentsDirectory();
    //       final filePath = Platform.isAndroid
    //           ? '${appDownloadsDir.path}/$fileName.jpg'
    //           : '${appDownloadsDir.path}/$fileName.jpg';

    //       if (!await appDownloadsDir.exists()) {
    //         await appDownloadsDir.create(recursive: true);
    //       }

    //       final file = File(filePath);
    //       await dio.download(imageUrl, file.path);

    //       if (context.mounted) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text('Imagen descargada en ${file.path}'),
    //           ),
    //         );
    //       }
    //     } else {
    //       if (context.mounted) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(
    //             content: Text('Permiso de almacenamiento denegado.'),
    //           ),
    //         );
    //       }
    //     }
    //   } catch (e) {
    //     if (context.mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text('Error al descargar la imagen: $e'),
    //         ),
    //       );
    //     }
    //   }
    // }

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
        final originalImageUrl = 'https://tapetestufan.mx/imagen/_web/$imageUrl';
        
        // Obtener token de autenticación
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'accessToken');
        
        // Endpoint de marca de agua - requiere POST
        final watermarkUrl = 'https://e.tapetestufan.mx/add-watermark/';
        
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
          text: 'te comparto la imagen del producto ${imageUrl.split('/').first}',
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

    // Future<void> sendToWhatsApp(String imageUrl, String fileName) async {
    //   try {
    //     final appDownloadsDir = await getTemporaryDirectory();
    //     final file = File('${appDownloadsDir.path}/$fileName.jpg');
    //     await dio.download(imageUrl, file.path);

    //     final whatsappUrl = Uri.parse(
    //         'whatsapp://send?phone=$clientPhoneNumber&text=Hola Soy $userName, te comparto la imagen del producto $fileName.');

    //     if (await canLaunchUrl(whatsappUrl)) {
    //       await launchUrl(whatsappUrl);

    //       // Share image to WhatsApp
    //       await Share.shareXFiles([XFile(file.path)],
    //           text:
    //               'Hola Soy $userName, te comparto la imagen del producto $fileName.');
    //     } else {
    //       if (context.mounted) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(
    //             content: Text('No se pudo abrir WhatsApp.'),
    //           ),
    //         );
    
    //       }
    //     }
    //   } catch (e) {
    //     if (context.mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text('Error al enviar a WhatsApp: $e'),
    //         ),
    //       );
    //     }
    //   }
    // }

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
          // IconButton(
          //   icon: const Icon(Icons.download),
          //   onPressed: () => downloadImage(imageUrls[initialIndex], 'image_${initialIndex + 1}'),
          // ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => shareImage(widget.imageUrls[_currentIndex]),
          ),
          // IconButton(
          //   icon: const FaIcon(FontAwesomeIcons.whatsapp),
          //   onPressed: () => sendToWhatsApp(
          //       imageUrls[initialIndex], 'image_${initialIndex + 1}'),
          // ),
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
                        'https://tapetestufan.mx/imagen/_web/${Uri.encodeFull(widget.imageUrls[index])}',
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
                  'Precio Expo: ${Utils.formatPrice(widget.producto.precio2.toDouble())}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Precio Mayoreo: ${Utils.formatPrice(widget.producto.precio3.toDouble())}',
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
