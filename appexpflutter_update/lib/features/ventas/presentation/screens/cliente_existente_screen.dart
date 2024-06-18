import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'widgets/widgets.dart' show SearchClientes;

class ClienteExistenteScreen extends StatelessWidget {
  const ClienteExistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'CLIENTE EXISTENTE',
      faIcon: FontAwesomeIcons.userCheck,
      child: const SearchClientes(),
    );
  }
}
