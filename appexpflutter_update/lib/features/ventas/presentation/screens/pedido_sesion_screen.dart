import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/search_producto.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lista_productos.dart';

import 'widgets/widgets.dart' show CustomDropdownButton;

const list = [
  'Pendiente Pago (Anticipo)',
  'Pagado Foráneo',
  'Pagado (Recoger en tienda)'
];

class PedidoSesionScreen extends StatefulHookWidget {
  const PedidoSesionScreen({
    super.key,
    required this.idCliente,
    required this.nombreCliente,
    required this.estado,
  });
  final int idCliente;
  final String nombreCliente;
  final int estado;

  @override
  State<PedidoSesionScreen> createState() => _PedidoSesionScreenState();
}

class _PedidoSesionScreenState extends State<PedidoSesionScreen> {
  int getEstadoPedidoPagoId(String metodo) {
    return list.indexOf(metodo) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState<String>(list[widget.estado - 1]);
    final productos = context.watch<ProductosBloc>().scannedProducts;
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'PEDIDO',
      floatingActionButton: ElevatedButton(
        onPressed: () {
          if (productos.isNotEmpty) {
            GenerarPedidoRoute(
                    idCliente: widget.idCliente,
                    estadoPedido: getEstadoPedidoPagoId(dropdownValue.value))
                .push(context);
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Atención'),
                  content: const Text('Debes agregar algún producto'),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colores.secondaryColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Aceptar',
                        style:
                            TextStyle(color: Colores.scaffoldBackgroundColor),
                      ),
                    )
                  ],
                );
              },
            );
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
        ),
        child: Image.asset(
          'assets/iconos/generar pedido- rosa.png',
          scale: 4.5,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Cliente: ',
                    style: TextStyle(
                        color: Colores.scaffoldBackgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  AutoSizeText(
                    maxLines: 2,
                    widget.nombreCliente,
                    style: const TextStyle(
                        color: Colores.scaffoldBackgroundColor, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Center(
                child: CustomDropdownButton<String>(
                  value: dropdownValue.value,
                  hint: 'Selecciona Estatus del pedido',
                  styleHint: const TextStyle(fontSize: 15),
                  prefixIcon: const FaIcon(
                    FontAwesomeIcons.bagShopping,
                    color: Colores.secondaryColor,
                  ),
                  onChanged: (value) {
                    dropdownValue.value = value!;
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
              const SizedBox(height: 20),
              SearchProducto(
                  estatusPedido: getEstadoPedidoPagoId(dropdownValue.value),
                  idCliente: widget.idCliente),
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
                    return ListaProductos(productos: state.productos);
                  } else if (state is ProductoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductoError) {
                    return ListaProductos(
                      productos: state.productos,
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
