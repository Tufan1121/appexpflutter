import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/producto_card.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/search_prices.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/shared/widgets/widgets.dart'
    show LayoutScreens;

class PreciosScreen extends StatelessWidget {
  const PreciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
      icon: Icons.price_change,
      titleScreen: 'PRECIOS',
      child: Column(
        children: [
          const SearchPrices(),
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

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    ProductoCard(
                      producto: state.producto,
                      existencia: existencia,
                    ),
                    const SizedBox(height: 5),
                    _buildRelatedProductsList(context, state.productos),
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
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16.0),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          )
        ],
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
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
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


