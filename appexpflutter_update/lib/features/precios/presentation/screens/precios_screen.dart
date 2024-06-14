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

class ProductoCard extends StatelessWidget {
  final ProductoEntity producto;
  final double existencia;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.existencia,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              producto.producto,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Clave', producto.producto1),
            _buildInfoRow('Existencia en Bodegas', existencia.toString()),
            _buildInfoRow('Medidas', producto.medidas),
            _buildInfoRow(
                'Precio Lista', Utils.formatPrice(producto.precio1.toDouble())),
            _buildInfoRow(
                'Precio Expo', Utils.formatPrice(producto.precio2.toDouble())),
            _buildInfoRow('Precio Mayoreo',
                Utils.formatPrice(producto.precio3.toDouble())),
            _buildCompositionRow(
                'Composición', '${producto.compo1} ${producto.compo2}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
          ),
          Expanded(
            child: AutoSizeText(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.end,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          AutoSizeText(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AutoSizeText(
              value,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
