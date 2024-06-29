import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../shared/widgets/layout_screens.dart';
import 'widgets/widgets.dart';

class ClienteNuevoScreen extends StatelessWidget {
  const ClienteNuevoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'CLIENTE NUEVO',
      faIcon: FontAwesomeIcons.userPlus,
      child: Column(
        children: [
          const SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 470,
              child: Card(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: size.height * 0.70,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 20),
                          Flexible(flex: 1, child: ClienteForm()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
