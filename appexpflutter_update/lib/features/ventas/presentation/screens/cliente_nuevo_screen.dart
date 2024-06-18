import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../shared/widgets/layout_screens.dart';
import 'widgets/widgets.dart';

class ClienteNuevoScreen extends StatelessWidget {
  const ClienteNuevoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'CLIENTE NUEVO',
      faIcon: FontAwesomeIcons.userPlus,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(child: SizedBox(height: 500, child: ClienteForm())),
      ),
    );
  }
}
