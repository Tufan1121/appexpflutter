import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lista_productos_bodega.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_search.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/producto/productos_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';

class InventarioBodega extends StatefulWidget {
  const InventarioBodega({super.key});

  @override
  State<InventarioBodega> createState() => _InventarioBodegaState();
}

class _InventarioBodegaState extends State<InventarioBodega> {
  bool isMultiSelectMode = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.71, // Altura inicial del modal
      minChildSize: 0.2, // Altura mínima del modal
      maxChildSize: 0.9, // Altura máxima del modal
      builder: (BuildContext context, ScrollController scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Barra indicativa para cerrar el modal
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colores.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'INVENTARIO EN BODEGAS',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colores.secondaryColor,
                    shadows: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2.0, 5.0),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMultiSelectMode)
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    context
                        .read<ProductosBloc>()
                        .add(AddSelectedProductsToScannedEvent());
                    setState(() {
                      isMultiSelectMode = false;
                    });
                  },
                ),
              const SizedBox(height: 10),
              CustomSearch(
                hintText: 'Calidad',
                onChanged: (value) {},
                onSubmitted: (value) => context
                    .read<ProductosBloc>()
                    .add(GetIbodegaProductEvent(data: {'descripcio': value})),
              ),
              const SizedBox(height: 5),
              BlocBuilder<ProductosBloc, ProductosState>(
                builder: (context, state) {
                  if (state is IbodegaProductosLoading) {
                    return const Column(
                      children: [
                        SizedBox(height: 150),
                        CircularProgressIndicator(
                          color: Colores.secondaryColor,
                        ),
                      ],
                    );
                  }
                  if (state is IbodegaProductosLoaded) {
                    final productos = state.productos;
                    final selectedProducts = state.selectedProducts;

                    return Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          final isSelected =
                              selectedProducts.contains(producto);
                          final existencia = productos[index].bodega1 +
                              productos[index].bodega2 +
                              productos[index].bodega3 +
                              productos[index].bodega4;
                          return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  isMultiSelectMode = true;
                                });
                                context
                                    .read<ProductosBloc>()
                                    .add(StartMultiSelectEvent());
                              },
                              onTap: () {
                                if (isMultiSelectMode) {
                                  context.read<ProductosBloc>().add(
                                      ToggleProductSelectionEvent(producto));
                                } else {
                                  context
                                      .read<ProductosBloc>()
                                      .add(AddProductToScannedEvent(producto));
                                }
                              },
                              child: ListaProductosBodegaCard(
                                producto: producto,
                                isSelected: isSelected,
                                existencia: existencia.toInt(),
                                isMultiSelectMode: isMultiSelectMode,
                              ));
                        },
                      ),
                    );
                  }
                  if (state is ProductoError) {
                    return Column(
                      children: [
                        const SizedBox(height: 150),
                        Center(
                          child: SizedBox(
                            height: 60,
                            width: 300,
                            child: Card(
                              child: AutoSizeText(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: Container(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
