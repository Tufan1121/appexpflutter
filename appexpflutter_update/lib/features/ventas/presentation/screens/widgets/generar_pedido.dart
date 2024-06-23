import 'package:flutter/material.dart';

import '../../../../shared/widgets/layout_screens.dart';

class GenerarPedidoScreen extends StatelessWidget {
  const GenerarPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
        onPressed: () => Navigator.pop(context), titleScreen: 'GENERAR PEDIDO');
  }
}
