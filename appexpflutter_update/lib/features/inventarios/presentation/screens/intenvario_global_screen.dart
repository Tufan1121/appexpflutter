import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:flutter/material.dart';

class BusquedaGlobalScreen extends StatelessWidget {
  const BusquedaGlobalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
      onPressed: () {
        Navigator.pop(context);
      },
      titleScreen: 'BUSQUEDA GLOBAL',
    );
  }
}
