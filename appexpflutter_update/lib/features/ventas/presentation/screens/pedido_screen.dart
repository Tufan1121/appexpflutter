import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/search_producto.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lista_productos.dart';

import 'widgets/widgets.dart' show CustomDropdownButton;

const list = [
  'Pendiente Pago (Anticipo)',
  'Pagado Foráneo',
  'Pagado (Recoger en tienda)'
];

class PedidoScreen extends StatefulHookWidget {
  const PedidoScreen({super.key, required this.idCliente});
  final int idCliente;

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState<String>(list.first);
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'PEDIDO',
      child: Column(
        children: [
          const SizedBox(height: 20),
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
          const SizedBox(height: 25),
          SearchProducto(
              estatusPedido: dropdownValue.value,
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
    );
  }
}
