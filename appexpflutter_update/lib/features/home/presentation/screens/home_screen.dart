import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: BackgroundPainter(),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            tooltip: 'Cerrar Sesión',
                            color: Colores.scaffoldBackgroundColor,
                            onPressed: () async {
                              await context
                                  .read<AuthBloc>()
                                  .deleteAccessToken();
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
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 20,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    CardItem(
                      icon: Icons.qr_code,
                      label: 'Precios',
                      onTap: () => PreciosRoute().push(context),
                    ),
                    const CardItem(
                      icon: Icons.shopping_cart_rounded,
                      label: 'Nueva Seccion de Ventas',
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
