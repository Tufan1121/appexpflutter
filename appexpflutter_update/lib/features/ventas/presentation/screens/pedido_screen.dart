import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/search_producto.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          SearchProducto(),
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
}
