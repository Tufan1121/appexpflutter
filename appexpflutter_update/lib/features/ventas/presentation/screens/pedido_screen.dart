import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/search_producto.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
      child: Column(
        children: [
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
          const SearchProducto()
        ],
      ),
    );
  }
}
