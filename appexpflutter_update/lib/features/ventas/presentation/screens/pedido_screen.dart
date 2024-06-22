import 'package:appexpflutter_update/config/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/search_producto.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/widgets.dart' show CustomDropdownButton;

const list = [
  'Pendiente Pago (Anticipo)',
  'Pagado Foráneo',
  'Pagado (Recoger en tienda)'
];

class PedidoScreen extends StatefulHookWidget {
  const PedidoScreen({super.key, required this.clienteEntity});
  final ClienteEntity clienteEntity;

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  String dropdownValue = list.first;
  Map<String, bool?> selectedPrices = {};
  Map<String, int> productQuantities = {};

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
        onPressed: () => Navigator.pop(context),
        titleScreen: 'PEDIDO',
        child: Column(children: [
          const SizedBox(height: 20),
          Center(
            child: CustomDropdownButton<String>(
              hint: 'Selecciona Estatus del pedido',
              styleHint: const TextStyle(fontSize: 15),
              prefixIcon: const FaIcon(
                FontAwesomeIcons.bagShopping,
                color: Colores.secondaryColor,
              ),
              onChanged: (value) {
                dropdownValue = value!;
              },
              icon: const FaIcon(
                FontAwesomeIcons.diagramNext,
                color: Colores.secondaryColor,
              ),
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: AutoSizeText(
                    value,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 25),
          const SearchProducto(),
          const SizedBox(height: 5),
          BlocConsumer<ProductosBloc, ProductosState>(
            listener: (context, state) {
              if (state is ProductoError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                  ),
                ));
              }
            },
            builder: (context, state) {
              if (state is ProductosLoaded) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: ListView.builder(
                    itemCount: state.productos.length,
                    itemBuilder: (context, index) {
                      final producto = state.productos[index];
                      final isSelectedPrice1 =
                          selectedPrices[producto.producto1] ?? false;
                      final quantity =
                          productQuantities[producto.producto1] ?? 1;
                      final existencia = state.productos[index].bodega1 +
                          state.productos[index].bodega2 +
                          state.productos[index].bodega3 +
                          state.productos[index].bodega4;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Dismissible(
                          key: Key(producto.producto1),
                          onDismissed: (direction) {
                            context
                                .read<ProductosBloc>()
                                .add(RemoveProductEvent(producto));
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1)}', // Reemplaza con la URL de la imagen del producto
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producto.producto,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Clave: ${producto.producto1}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Existencia: ${existencia.toInt()}', // Asegúrate de que `producto.dimensiones` sea un campo válido
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              productQuantities[producto
                                                  .producto1] = quantity + 1;
                                            });
                                          },
                                        ),
                                        Text('$quantity'),
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              if (quantity > 1) {
                                                productQuantities[producto
                                                    .producto1] = quantity - 1;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildPriceCheckbox(
                                      context: context,
                                      label: 'Precio de Lista',
                                      price: producto.precio1.toDouble(),
                                      onChanged: (p0) {},
                                    ),
                                    _buildPriceCheckbox(
                                      context: context,
                                      label: 'Precio de Expo',
                                      price: producto.precio2.toDouble(),
                                      onChanged: (p0) {},
                                    ),
                                    _buildPriceCheckbox(
                                      context: context,
                                      label: 'Precio Mayoreo',
                                      price: producto.precio3.toDouble(),
                                      onChanged: (p0) {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (state is ProductoLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProductoError) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: ListView.builder(
                    itemCount: state.productos.length,
                    itemBuilder: (context, index) {
                      final producto = state.productos[index];
                      return ClipRect(
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          clipBehavior: Clip.hardEdge,
                          child: Dismissible(
                            key: Key(producto.producto1),
                            onDismissed: (direction) {
                              context
                                  .read<ProductosBloc>()
                                  .add(RemoveProductEvent(producto));
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              leading: Icon(Icons.shopping_cart,
                                  color: Theme.of(context).primaryColor),
                              title: Text(producto.producto),
                              subtitle: Text('Precio: \$${producto.precio1}'),
                              trailing: Text('Cantidad: ${producto.bodega1}'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          )
        ]));
  }

  Widget _buildPriceCheckbox(
      {required BuildContext context,
      String? label,
      required double price,
      bool? value,
      required void Function(bool?)? onChanged}) {
    return Column(
      children: [
        Text(label ?? ''),
        Row(
          children: [
            Checkbox(
              value: value ?? false,
              onChanged: onChanged,
            ),
            Text(Utils.formatPrice(price)),
          ],
        ),
      ],
    );
  }
}
