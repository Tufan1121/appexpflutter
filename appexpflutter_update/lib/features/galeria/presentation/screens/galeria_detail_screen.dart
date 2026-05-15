import 'dart:io';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_galeria/detalle_galeria_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_producto/detalle_producto_bloc.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:galeria/domain/entities/producto_inv_entity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GaleriaDetailScreen extends StatefulWidget {
  final String? userName;

  const GaleriaDetailScreen({super.key, this.userName});

  @override
  State<GaleriaDetailScreen> createState() => _GaleriaDetailScreenState();
}

class _GaleriaDetailScreenState extends State<GaleriaDetailScreen> {
  final dio = Dio();
  late PageController _pageController;
  late int _currentIndex;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detalleKey = GlobalKey();

  List<bool> isLoadingList = [];

  int? activeLoadingIndex; // Índice del botón actualmente en estado de carga

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _currentIndex = 0;
  }

  Future<void> _scrollToDetalle() async {
    await Future.delayed(const Duration(
        milliseconds:
            300)); // Espera para asegurar que la UI esté completamente renderizada
    if (_scrollController.hasClients) {
      final renderBox =
          _detalleKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && context.mounted) {
        final position = renderBox.localToGlobal(Offset.zero,
            ancestor: _scrollController.position.context.storageContext
                .findRenderObject());
        _scrollController.animateTo(
          position.dy + _scrollController.offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
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
              'Te comparto la imagen del producto ${imageUrl.split('/').first}',
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

    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        context.read<DetalleGaleriaBloc>().add(ResetDetalleGaleriaEvent());
        context.read<DetalleProductoBloc>().add(ResetDetalleProductoEvent());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 0.7],
                ),
              ),
            ),
            Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(40.0),
                  child: CustomAppBar(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    onPressed: () {
                      context.read<DetalleGaleriaBloc>().add(ResetDetalleGaleriaEvent());
                      context.read<DetalleProductoBloc>().add(ResetDetalleProductoEvent());
                      Navigator.pop(context);
                    },
                    title: 'GALERÍA',
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: BlocBuilder<DetalleGaleriaBloc, DetalleGaleriaState>(
          builder: (context, state) {
            if (state is DetalleGaleriaLoaded) {
              // Inicializar la lista de carga si aún no está inicializada
              if (isLoadingList.isEmpty) {
                isLoadingList =
                    List<bool>.filled(state.productosConMedidas.length, false);
              }
              return Scrollbar(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // En horizontal/ancho usamos un Wrap con cards de
                        // ancho fijo (2-4 columnas según el ancho disponible)
                        // para que la foto no se estire y entren varias
                        // fichas por renglón. En portrait queda 1 columna
                        // como antes.
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            int cols;
                            if (w >= 1280) {
                              cols = 4;
                            } else if (w >= 900) {
                              cols = 3;
                            } else if (w >= 600) {
                              cols = 2;
                            } else {
                              cols = 1;
                            }
                            const spacing = 12.0;
                            final cardWidth = cols == 1
                                ? w
                                : (w - (cols - 1) * spacing) / cols;
                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: List.generate(
                                  state.productosConMedidas.length, (index) {
                                final productoConMedidas =
                                    state.productosConMedidas[index];
                                return SizedBox(
                                  width: cardWidth,
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 3.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _FotoCarousel(
                                            fotos: [
                                              productoConMedidas
                                                  .producto.pathima1,
                                              productoConMedidas
                                                  .producto.pathima2,
                                              productoConMedidas
                                                  .producto.pathima3,
                                              productoConMedidas
                                                  .producto.pathima4,
                                              productoConMedidas
                                                  .producto.pathima5,
                                              productoConMedidas
                                                  .producto.pathima6,
                                            ]
                                                .where((p) =>
                                                    p.trim().isNotEmpty)
                                                .toList(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0, bottom: 6.0),
                                            child: Text(
                                              '${productoConMedidas.producto.descripcio} - ${productoConMedidas.producto.diseno}',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 4.0,
                                            runSpacing: 2.0,
                                            children: productoConMedidas
                                                .medidas
                                                .map((medida) {
                                              return Chip(
                                                label: Text(
                                                  medida.medidas,
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 11,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                ),
                                                backgroundColor: theme
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(0.1),
                                              );
                                            }).toList(),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: BlocListener<
                                                DetalleProductoBloc,
                                                DetalleProductoState>(
                                              listener: (context, state) {
                                                if (state
                                                        is DetalleProductoLoaded ||
                                                    state
                                                        is DetalleProductoError) {
                                                  _scrollToDetalle();
                                                  if (activeLoadingIndex !=
                                                      null) {
                                                    setState(() {
                                                      isLoadingList[
                                                              activeLoadingIndex!] =
                                                          false;
                                                      activeLoadingIndex = null;
                                                    });
                                                  }
                                                }
                                              },
                                              child: TextButton(
                                                onPressed: isLoadingList[index]
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          isLoadingList[
                                                              index] = true;
                                                          activeLoadingIndex =
                                                              index;
                                                        });
                                                        context
                                                            .read<
                                                                DetalleProductoBloc>()
                                                            .add(
                                                              GetProductsEvent(
                                                                  producto:
                                                                      productoConMedidas
                                                                          .producto),
                                                            );
                                                      },
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 6.0),
                                                  backgroundColor: theme
                                                      .colorScheme.primary
                                                      .withOpacity(0.1),
                                                ),
                                                child: Text(
                                                  isLoadingList[index]
                                                      ? 'Cargando...'
                                                      : 'Ver Detalles',
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        BlocBuilder<DetalleProductoBloc, DetalleProductoState>(
                          builder: (context, state) {
                            if (state is DetalleProductoLoading) {
                              return Column(
                                children: [
                                  const SizedBox(height: 100),
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              );
                            }

                            if (state is DetalleProductoError) {
                              return Center(
                                child: Text(state.message),
                              );
                            }

                            if (state is DetalleProductoLoaded) {
                              final imageUrls = [
                                state.productosConExistencias.producto.pathima1,
                                state.productosConExistencias.producto.pathima2,
                                state.productosConExistencias.producto.pathima3
                              ];

                              return Column(
                                key: _detalleKey,
                                children: [
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.7,
                                    child: Stack(
                                      children: [
                                        PhotoViewGallery.builder(
                                          pageController: _pageController,
                                          itemCount: imageUrls.length,
                                          builder: (context, index) {
                                            return PhotoViewGalleryPageOptions(
                                              imageProvider: NetworkImage(
                                                'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(imageUrls[index])}',
                                              ),
                                              initialScale:
                                                  PhotoViewComputedScale
                                                      .contained,
                                              minScale: PhotoViewComputedScale
                                                  .contained,
                                              maxScale: PhotoViewComputedScale
                                                      .covered *
                                                  2,
                                              heroAttributes:
                                                  PhotoViewHeroAttributes(
                                                tag: imageUrls[index],
                                              ),
                                            );
                                          },
                                          backgroundDecoration:
                                              BoxDecoration(
                                            color:
                                                theme.scaffoldBackgroundColor,
                                          ),
                                          onPageChanged: (index) {
                                            setState(() {
                                              _currentIndex = index;
                                            });
                                          },
                                        ),
                                        Positioned(
                                          bottom: 30,
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7, // Ajusta la posición horizontal
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05, // Ajusta el margen derecho
                                          child: IconButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all<
                                                          Color>(
                                                      theme.colorScheme.primary),
                                              shape: WidgetStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                            ),
                                            onPressed: () => shareImage(
                                                imageUrls[_currentIndex]),
                                            icon: FaIcon(
                                              FontAwesomeIcons.shareNodes,
                                              color: theme
                                                  .scaffoldBackgroundColor,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      state.productosConExistencias.producto
                                          .descripcio,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      state.productosConExistencias.producto
                                          .diseno,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Divider(
                                        color: theme.colorScheme.primary,
                                        thickness: 1.0,
                                      ),
                                      ListTile(
                                        title: Text(
                                          'Origen:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          state.productosConExistencias.producto
                                              .origenn,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'Composición:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${state.productosConExistencias.producto.compo1}, ${state.productosConExistencias.producto.compo2}.',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'Lavado:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${state.productosConExistencias.producto.lava1}, ${state.productosConExistencias.producto.lava2}.',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: theme.colorScheme.primary,
                                        thickness: 1.0,
                                      ),
                                      // Tabla "Medidas y Precios en Existencia"
                                      // y columnas de descuentos ocultas para
                                      // la rama promos (los promotores no ven
                                      // precios). Solo se muestra existencias
                                      // por almacén.
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final medidasEntries = state
                                              .productosConExistencias
                                              .existencias
                                              .groupListsBy((e) => e.medidas)
                                              .entries
                                              .toList();
                                          final w = constraints.maxWidth;
                                          int cols;
                                          if (w >= 1280) {
                                            cols = 4;
                                          } else if (w >= 900) {
                                            cols = 3;
                                          } else if (w >= 600) {
                                            cols = 2;
                                          } else {
                                            cols = 1;
                                          }
                                          const spacing = 12.0;
                                          final cardWidth = cols == 1
                                              ? w
                                              : (w - (cols - 1) * spacing) /
                                                  cols;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Wrap(
                                              spacing: spacing,
                                              runSpacing: spacing,
                                              children: medidasEntries
                                                  .map((entry) {
                                                final medida = entry.key;
                                                final existencias = entry.value;
                                                return SizedBox(
                                                  width: cardWidth,
                                                  child: Card(
                                                    margin: EdgeInsets.zero,
                                                    elevation: 3.0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    child: ExpansionTile(
                                                      expandedCrossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      title: Text(
                                                        'Medida: $medida',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                        ),
                                                      ),
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16.0,
                                                                  vertical:
                                                                      8.0),
                                                          child:
                                                              _buildExistenciasTable(
                                                                  existencias),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is DetalleGaleriaLoading) {
              return Center(
                  child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ));
            } else if (state is DetalleGaleriaError) {
              return Center(child: Text(state.message));
            } else {
              return const SizedBox();
            }
          },
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  // Método para construir la tabla de existencias
  Widget _buildExistenciasTable(List<ProductoInvEntity> existencias) {
    return DataTable(
      columns: const [
        DataColumn(
          label: Text(
            'Almacén',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Existencias',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: existencias.map((existencia) {
        return DataRow(
          cells: [
            DataCell(Text(existencia.desalmacen)),
            DataCell(Text(existencia.hm.toString())),
          ],
        );
      }).toList(),
    );
  }
}

/// Carrusel horizontal de fotos del producto (`pathima1..pathima6` que no
/// estén vacías). PageView para swipe + indicador de puntos + contador.
class _FotoCarousel extends StatefulWidget {
  final List<String> fotos;

  const _FotoCarousel({required this.fotos});

  @override
  State<_FotoCarousel> createState() => _FotoCarouselState();
}

class _FotoCarouselState extends State<_FotoCarousel> {
  final PageController _pc = PageController();
  int _idx = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.fotos.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: theme.disabledColor,
            ),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pc,
              itemCount: widget.fotos.length,
              onPageChanged: (i) => setState(() => _idx = i),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) => FadeInImage(
                image: NetworkImage(
                    'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(widget.fotos[i])}'),
                placeholder: const AssetImage('assets/loaders/loading.gif'),
                fit: BoxFit.contain,
                width: double.infinity,
                fadeInDuration: const Duration(milliseconds: 300),
                imageErrorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/no-image.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (widget.fotos.length > 1) ...[
              // Contador "1/3" en esquina sup. derecha.
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_idx + 1}/${widget.fotos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Puntos de paginación al pie.
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.fotos.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _idx
                            ? theme.colorScheme.primary
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
