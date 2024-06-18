import 'package:appexpflutter_update/config/config.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/producto_card.dart';
import 'package:appexpflutter_update/config/utils.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/search_prices.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/shared/widgets/widgets.dart'
    show CustomFilledButton2, LayoutScreens;

class PreciosScreen extends StatelessWidget {
  const PreciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<PreciosBloc>().add(ClearPreciosStateEvent());
      },
      child: LayoutScreens(
        icon: Icons.price_change,
        titleScreen: 'PRECIOS',
        onPressed: () {
          context.read<PreciosBloc>().add(
              ClearPreciosStateEvent()); // Limpia el estado al salir de la pantalla
          Navigator.pop(context);
        },
        child: SizedBox(
          height: screenHeight * 0.75,
          child: Column(
            children: [
              const SearchPrices(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      BlocBuilder<PreciosBloc, PreciosState>(
                        builder: (context, state) {
                          if (state is PreciosLoading) {
                            return const Column(
                              children: [
                                SizedBox(height: 150),
                                CircularProgressIndicator(
                                  color: Colores.secondaryColor,
                                ),
                              ],
                            );
                          } else if (state is PreciosLoaded) {
                            double existencia = state.producto.bodega1 +
                                state.producto.bodega2 +
                                state.producto.bodega3 +
                                state.producto.bodega4;

                            List<String> imagePaths = [
                              state.producto.pathima1,
                              state.producto.pathima2,
                              state.producto.pathima3,
                              state.producto.pathima4,
                              state.producto.pathima5,
                              state.producto.pathima6,
                            ].where((path) => path.isNotEmpty).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 8),
                                ProductoCard(
                                  imagen:
                                      'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(state.producto.pathima1)}',
                                  producto: state.producto,
                                  existencia: existencia,
                                  onTap: () => PhotoGalleryRoute(
                                          imageUrls: imagePaths,
                                          initialIndex: 0)
                                      .push(context),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: CustomFilledButton2(
                                    buttonColor: Colores.secondaryColor,
                                    onPressed: () => context
                                        .read<PreciosBloc>()
                                        .add(GetRelativedProductsEvent(
                                            producto: state.producto)),
                                    text: 'Productos relacionados',
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                            );
                          } else if (state is PreciosRelativosLoaded) {
                            double existencia = state.producto.bodega1 +
                                state.producto.bodega2 +
                                state.producto.bodega3 +
                                state.producto.bodega4;

                            List<String> imagePaths = [
                              state.producto.pathima1,
                              state.producto.pathima2,
                              state.producto.pathima3,
                              state.producto.pathima4,
                              state.producto.pathima5,
                              state.producto.pathima6,
                            ].where((path) => path.isNotEmpty).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 5),
                                ProductoCard(
                                  imagen:
                                      'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(state.producto.pathima1)}',
                                  producto: state.producto,
                                  existencia: existencia,
                                  onTap: () => PhotoGalleryRoute(
                                          imageUrls: imagePaths,
                                          initialIndex: 0)
                                      .push(context),
                                ),
                                const SizedBox(height: 5),
                                _buildRelatedProductsList(
                                    context, state.productos),
                              ],
                            );
                          } else if (state is PreciosError) {
                            return Column(
                              children: [
                                const SizedBox(height: 150),
                                Center(
                                  child: Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16.0),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedProductsList(
      BuildContext context, List<ProductoEntity> productosRelacionados) {
    return productosRelacionados.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AutoSizeText(
                'Productos Relacionados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  itemCount: productosRelacionados.length,
                  itemBuilder: (context, index) {
                    final productoRelacionado = productosRelacionados[index];
                    return Card(
                      child: ListTile(
                        title: AutoSizeText(productoRelacionado.producto,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        onTap: () {
                          context.read<PreciosBloc>().add(
                              SelectRelatedProductEvent(productoRelacionado));
                        },
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                                "Clave: ${productoRelacionado.producto1}"),
                            AutoSizeText(
                                "Precio: ${Utils.formatPrice(productoRelacionado.precio1.toDouble())}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
