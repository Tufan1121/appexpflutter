import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/card_item.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PuntoVentaScreen extends HookWidget {
  const PuntoVentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(40.0),
                child: CustomAppBar(
                  backgroundColor: Colors.transparent,
                  color: Colores.secondaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: 'COTIZACIÓN',
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 20,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    CardItem(
                      icon: Icons.point_of_sale_sharp,
                      label: 'TICKETS',
                      onTap: () => ClienteNuevoVentaRoute().push(context),
                    ),
                    CardItem(
                      icon: Icons.history_rounded,
                      label: 'CONSULTA',
                      onTap: () => PuntoVentaHistoryRoute().push(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
