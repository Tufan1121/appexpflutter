import 'dart:io';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/producto_inv_entity.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_galeria/detalle_galeria_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_producto/detalle_producto_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:collection/collection.dart';

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

  late MedidasDataSource _medidasDataSource;

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
      try {
        final appDownloadsDir = await getTemporaryDirectory();
        final file =
            File('${appDownloadsDir.path}/${imageUrl.split('/').last}');
        await dio.download(
            'https://tapetestufan.mx:446/imagen/_web/$imageUrl', file.path);
        await Share.shareXFiles([XFile(file.path)],
            text:
                'Te comparto la imagen del producto ${imageUrl.split('/').first}');
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al compartir la imagen: $e')),
          );
        }
      }
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        context.read<DetalleGaleriaBloc>().add(ResetDetalleGaleriaEvent());
        context.read<DetalleProductoBloc>().add(ResetDetalleProductoEvent());
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colores.secondaryColor.withOpacity(0.78),
          title: Text(
            'Galería',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colores.scaffoldBackgroundColor,
            ),
          ),
        ),
        body: BlocBuilder<DetalleGaleriaBloc, DetalleGaleriaState>(
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.productosConMedidas.length,
                          itemBuilder: (context, index) {
                            final productoConMedidas =
                                state.productosConMedidas[index];
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12.0)),
                                      child: FadeInImage(
                                        image: NetworkImage(
                                            'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(productoConMedidas.producto.pathima1)}'),
                                        placeholder: const AssetImage(
                                            'assets/loaders/loading.gif'),
                                        width: double.infinity,
                                        height: 140,
                                        fadeInDuration:
                                            const Duration(milliseconds: 300),
                                        fit: BoxFit.cover,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/no-image.jpg',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 6.0),
                                      child: Text(
                                        '${productoConMedidas.producto.descripcio} - ${productoConMedidas.producto.diseno}',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colores.secondaryColor,
                                        ),
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 4.0,
                                      runSpacing: 2.0,
                                      children: productoConMedidas.medidas
                                          .map((medida) {
                                        return Chip(
                                          label: Text(
                                            medida.medidas,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                              color: Colores.secondaryColor,
                                            ),
                                          ),
                                          backgroundColor: Colores
                                              .scaffoldBackgroundColor
                                              .withOpacity(0.1),
                                        );
                                      }).toList(),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: BlocListener<DetalleProductoBloc,
                                          DetalleProductoState>(
                                        listener: (context, state) {
                                          if (state is DetalleProductoLoaded ||
                                              state is DetalleProductoError) {
                                            _scrollToDetalle();
                                            // Restablece el estado de carga solo del botón que estaba cargando
                                            if (activeLoadingIndex != null) {
                                              setState(() {
                                                isLoadingList[
                                                        activeLoadingIndex!] =
                                                    false;
                                                activeLoadingIndex =
                                                    null; // Restablecer el índice activo
                                              });
                                            }
                                          }
                                        },
                                        child: TextButton(
                                          onPressed: isLoadingList[index]
                                              ? null
                                              : () {
                                                  setState(() {
                                                    isLoadingList[index] = true;
                                                    activeLoadingIndex =
                                                        index; // Guarda el índice activo
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 6.0),
                                            backgroundColor: Colores
                                                .secondaryColor
                                                .withOpacity(0.1),
                                          ),
                                          child: Text(
                                            isLoadingList[index]
                                                ? 'Cargando...'
                                                : 'Ver Detalles',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colores.secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<DetalleProductoBloc, DetalleProductoState>(
                          builder: (context, state) {
                            if (state is DetalleProductoLoading) {
                              return const Column(
                                children: [
                                  SizedBox(height: 100),
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: Colores.secondaryColor,
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

                              final getMedidas = state
                                  .productosConExistencias.tablaPrecios
                                  .map((e) {
                                return Medidas(
                                  e.medidas,
                                  Utils.formatPrice(e.precio1.toDouble()),
                                  Utils.formatPrice(e.precio8.toDouble()),
                                  Utils.formatPrice(e.precio4.toDouble()),
                                  Utils.formatPrice(e.precio5.toDouble()),
                                  Utils.formatPrice(e.precio6.toDouble()),
                                  Utils.formatPrice(e.precio7.toDouble()),
                                );
                              }).toList();
                              _medidasDataSource =
                                  MedidasDataSource(getMedidas);

                              return Column(
                                key: _detalleKey,
                                children: [
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.7,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: PageView.builder(
                                            controller: _pageController,
                                            itemCount: imageUrls.length,
                                            itemBuilder: (context, index) {
                                              return PhotoView(
                                                backgroundDecoration:
                                                    const BoxDecoration(
                                                  color: Colores
                                                      .scaffoldBackgroundColor,
                                                ),
                                                imageProvider: NetworkImage(
                                                  'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(imageUrls[index])}',
                                                ),
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
                                            onPageChanged: (index) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 30,
                                          left: 300,
                                          right: 15,
                                          child: IconButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all<
                                                          Color>(
                                                      Colores.secondaryColor),
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
                                            icon: const FaIcon(
                                              FontAwesomeIcons.shareNodes,
                                              color: Colores
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
                                        color: Colores.secondaryColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      state.productosConExistencias.producto
                                          .diseno,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        color: Colores.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Divider(
                                        color: Colores.secondaryColor,
                                        thickness: 1.0,
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Origen:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colores.secondaryColor,
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
                                        title: const Text(
                                          'Composición:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colores.secondaryColor,
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
                                        title: const Text(
                                          'Lavado:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colores.secondaryColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${state.productosConExistencias.producto.lava1}, ${state.productosConExistencias.producto.lava2}.',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colores.secondaryColor,
                                        thickness: 1.0,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Medidas y Precios en Existencia',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              color: Colores.secondaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 250,
                                            child: SfDataGrid(
                                              source: _medidasDataSource,
                                              columns: <GridColumn>[
                                                GridColumn(
                                                  columnName: 'medida',
                                                  label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      'Medidas',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colores
                                                            .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GridColumn(
                                                  columnName: 'precioNormal',
                                                  label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      'Precio Normal',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colores
                                                            .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GridColumn(
                                                  columnName: 'descuento20',
                                                  label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      '-20%',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colores
                                                            .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GridColumn(
                                                  columnName: 'descuento30',
                                                  label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      '-30%',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colores
                                                            .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GridColumn(
                                                  columnName: 'descuento40',
                                                  label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      '-40%',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colores
                                                            .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GridColumn(
                                                  columnName: 'descuento50',
                                                  label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      '-50%',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colores
                                                            .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GridColumn(
                                                  columnName: 'descuento70',
                                                  label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      '-70%',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colores
                                                            .secondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(
                                            color: Colores.secondaryColor,
                                            thickness: 1.0,
                                          ),
                                          ...state.productosConExistencias
                                              .existencias
                                              // Agrupa las existencias por medidas
                                              .groupListsBy((existencia) =>
                                                  existencia.medidas)
                                              .entries
                                              .map((entry) {
                                            final medida = entry.key;
                                            final existencias = entry
                                                .value; // Existencias agrupadas por medida

                                            return Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                              elevation: 3.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: ExpansionTile(
                                                expandedCrossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                title: Text(
                                                  'Medida: $medida',
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colores.secondaryColor,
                                                  ),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8.0),
                                                    child:
                                                        _buildExistenciasTable(
                                                            existencias),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
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
              return const Center(
                  child: CircularProgressIndicator(
                color: Colores.secondaryColor,
              ));
            } else if (state is DetalleGaleriaError) {
              return Center(child: Text(state.message));
            } else {
              return const SizedBox();
            }
          },
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

// Clase para representar los datos de la tabla
class Medidas {
  Medidas(this.medida, this.precioNormal, this.descuento20, this.descuento30,
      this.descuento40, this.descuento50, this.descuento70);

  final String medida;
  final String precioNormal;
  final String descuento20;
  final String descuento30;
  final String descuento40;
  final String descuento50;
  final String descuento70;
}

// Fuente de datos para el DataGrid
class MedidasDataSource extends DataGridSource {
  MedidasDataSource(List<Medidas> medidas) {
    _medidas = medidas.map<DataGridRow>((e) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'medida', value: e.medida),
        DataGridCell<String>(columnName: 'precioNormal', value: e.precioNormal),
        DataGridCell<String>(columnName: 'descuento20', value: e.descuento20),
        DataGridCell<String>(columnName: 'descuento30', value: e.descuento30),
        DataGridCell<String>(columnName: 'descuento40', value: e.descuento40),
        DataGridCell<String>(columnName: 'descuento50', value: e.descuento50),
        DataGridCell<String>(columnName: 'descuento70', value: e.descuento70),
      ]);
    }).toList();
  }

  List<DataGridRow> _medidas = [];

  @override
  List<DataGridRow> get rows => _medidas;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}
