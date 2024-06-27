import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: BackgroundPainter2(),
          ),
          Column(
            children: [
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            size: 30,
                          ),
                          tooltip: 'Cerrar Sesión',
                          color: Colores.scaffoldBackgroundColor,
                          onPressed: () async {
                            await context.read<AuthBloc>().deleteAccessToken();
                            if (context.mounted) LoginRoute().go(context);
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/images/logo_tufan.png',
                        scale: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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
                      icon: Icons.price_change_rounded,
                      label: 'Precios',
                      onTap: () => PreciosRoute().push(context),
                    ),
                    CardItem(
                      icon: Icons.shopping_cart_rounded,
                      label: 'Nueva Sesión de Ventas',
                      onTap: () => showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Popover(
                            child: Container(
                              height: 160,
                              color: Colores.scaffoldBackgroundColor,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: ListView(
                                  children: [
                                    CustomListTile(
                                      text: 'CLIENTE NUEVO',
                                      icon: FontAwesomeIcons.userPlus,
                                      onTap: () =>
                                          ClienteNuevoRoute().push(context),
                                    ),
                                    const Divider(),
                                    CustomListTile(
                                      text: 'CLIENTE EXISTENTE',
                                      icon: FontAwesomeIcons.userCheck,
                                      onTap: () =>
                                          ClienteExistenteRoute().push(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const CardItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'Inventarios',
                    ),
                    const CardItem(
                      icon: Icons.history,
                      label: 'Historial',
                    ),
                    const CardItem(
                      icon: Icons.document_scanner_rounded,
                      label: 'Reportes',
                    ),
                    const CardItem(
                      icon: Icons.point_of_sale_sharp,
                      label: 'Punto de Venta',
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
