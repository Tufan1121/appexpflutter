import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_bodega/inventario_bodega_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/lista_productos_ibodega.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/custom_search.dart';

class IntentarioBodegaScreen extends StatelessWidget {
  const IntentarioBodegaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LayoutScreens(
      onPressed: () {
        Navigator.pop(context);
      },
      titleScreen: 'INVENTARIO BODEGA',
      child: Column(
        children: [
          const SizedBox(height: 10),
          CustomSearch(
            hintText: 'Calidad',
            onChanged: (value) {},
            onSubmitted: (value) => context
                .read<InventarioBodegaBloc>()
                .add(GetInventarioProductEvent(data: {'descripcio': value})),
          ),
          const SizedBox(height: 5),
          BlocBuilder<InventarioBodegaBloc, InventarioBodegaState>(
            builder: (context, state) {
              if (state is InventarioLoading) {
                return const Column(
                  children: [
                    SizedBox(height: 150),
                    CircularProgressIndicator(
                      color: Colores.secondaryColor,
                    ),
                  ],
                );
              }
              if (state is InventarioProductosLoaded) {
                final productos = state.productos;
                final selectedProducts = state.selectedProducts;

                return SizedBox(
                  height: size.height * 0.80,
                  child: ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      final isSelected = selectedProducts.contains(producto);
                      final existencia = productos[index].bodega1 +
                          productos[index].bodega2 +
                          productos[index].bodega3 +
                          productos[index].bodega4;
                      return ListaProductosIBodegaCard(
                        producto: producto,
                        isSelected: isSelected,
                        existencia: existencia.toInt(),
                      );
                    },
                  ),
                );
              }
              if (state is InventarioError) {
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
  }
}
