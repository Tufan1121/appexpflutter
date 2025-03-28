import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/producto_card.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/search_prices.dart';
import 'package:appexpflutter_update/features/shared/widgets/widgets.dart'
    show CustomFilledButton2;
import 'package:precios/domain/entities/producto_entity.dart';

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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/fondo.png',
                  ),
                  fit: BoxFit
                      .cover, // Asegura que la imagen de fondo se vea completa
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.90,
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: const Size.fromHeight(40.0),
                    child: CustomAppBar(
                      backgroundColor: Colors.transparent,
                      color: Colores.secondaryColor,
                      onPressed: () {
                        context.read<PreciosBloc>().add(
                            ClearPreciosStateEvent()); // Limpia el estado al salir de la pantalla
                        Navigator.pop(context);
                      },
                      title: 'PRECIOS',
                    ),
                  ),
                  const SearchPrices(),
                  Expanded(
                    child: Scrollbar(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 50),
                                      ProductoCard(
                                        imagen:
                                            'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(state.producto.pathima1)}',
                                        producto: state.producto,
                                        existencia: existencia.toInt(),
                                        onTap: () => PhotoGalleryRoute(
                                                imageUrls: imagePaths,
                                                medidas: state.producto.medidas,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 5),
                                      ProductoCard(
                                        imagen:
                                            'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(state.producto.pathima1)}',
                                        producto: state.producto,
                                        existencia: existencia.toInt(),
                                        onTap: () => PhotoGalleryRoute(
                                                imageUrls: imagePaths,
                                                medidas: state.producto.medidas,
                                                initialIndex: 0)
                                            .push(context),
                                      ),
                                      const SizedBox(height: 5),
                                      const Center(
                                        child: AutoSizeText(
                                          'Productos Relacionados',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      _buildRelatedProductsList(
                                          context, state.productos),
                                    ],
                                  );
                                } else if (state is PreciosError) {
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
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProductsList(
      BuildContext context, List<ProductoEntity> productosRelacionados) {
    return productosRelacionados.isEmpty
        ? Container()
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.30,
            child: ListView.builder(
              itemCount: productosRelacionados.length,
              itemBuilder: (context, index) {
                final productoRelacionado = productosRelacionados[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    child: ListTile(
                      title: AutoSizeText(productoRelacionado.producto,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      onTap: () {
                        context.read<PreciosBloc>().add(
                            GetRelativedProductsEvent(
                                producto: productoRelacionado));
                        context.read<PreciosBloc>().add(
                            SelectRelatedProductEvent(productoRelacionado));
                      },
                      subtitle: AutoSizeText(
                          "Clave: ${productoRelacionado.producto1}"),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
