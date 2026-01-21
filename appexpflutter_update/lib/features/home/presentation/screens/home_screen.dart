import 'package:appexpflutter_update/config/config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<(String, String)> username() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      prefs.getString('username') ?? '',
      prefs.getString('almacen') ?? ''
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GeometricalBackground(
        child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with logout button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                size: 24,
                              ),
                              tooltip: 'Cerrar Sesión',
                              color: Colors.white,
                              onPressed: () async {
                                context.read<AuthBloc>().add(const LogoutEvent());
                                if (context.mounted) LoginRoute().go(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Logo and welcome section
                      Center(
                        child: Column(
                          children: [
                            // Logo with glassmorphism container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo_tufan.png',
                                scale: 12,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // User info
                            FutureBuilder<(String, String)>(
                              future: username(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.white),
                                  );
                                } else if (snapshot.hasData) {
                                  final (username, almacen) = snapshot.data!;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '¡Bienvenido!',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Almacén: $almacen',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Text(
                                    'No data',
                                    style: TextStyle(color: Colors.white),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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
                      assetPathIcon: 'assets/iconos/qr/qr_72_.png',
                      label: 'Precios',
                      onTap: () => PreciosRoute().push(context),
                    ),
                    CardItem(
                      assetPathIcon: 'assets/iconos/precios__rosa_gris.png',
                      label: 'Nueva Sesión de Ventas',
                      onTap: () => homeModalButtom(
                          height: 160,
                          context: context,
                          child: ListView(
                            children: [
                              CustomListTile(
                                text: 'CLIENTE NUEVO',
                                assetPathIcon:
                                    'assets/iconos/cliente_nuevo__rosa_gris.png',
                                onTap: () => ClienteNuevoRoute().push(context),
                              ),
                              CustomListTile(
                                text: 'CLIENTE EXISTENTE',
                                assetPathIcon:
                                    'assets/iconos/cliente_existente__rosa_gris.png',
                                onTap: () =>
                                    ClienteExistenteRoute().push(context),
                              ),
                            ],
                          )),
                    ),
                    CardItem(
                      assetPathIcon:
                          'assets/iconos/inventarios__rosa_gris.png',
                      label: 'Inventarios',
                      onTap: () => homeModalButtom(
                          context: context,
                          height: 220,
                          child: ListView(
                            children: [
                              CustomListTile(
                                text: 'INVENTARIO EXPO',
                                assetPathIcon:
                                    'assets/iconos/inventario_expo__rosa.png',
                                onTap: () => InvetarioExpoRoute().push(context),
                              ),
                              CustomListTile(
                                  text: 'INVENTARIO BODEGAS',
                                  assetPathIcon:
                                      'assets/iconos/inventario_bodegas__rosa2.png',
                                  onTap: () {
                                    InvetarioBodegaRoute().push(context);
                                  }),
                              CustomListTile(
                                text: 'BUSQUEDA GLOBAL',
                                assetPathIcon:
                                    'assets/iconos/busqueda_global__rosa.png',
                                onTap: () =>
                                    BusquedaGlobalRoute().push(context),
                              ),
                            ],
                          )),
                    ),
                    CardItem(
                      icon: Icons.history_rounded,
                      label: 'Historial',
                      onTap: () => HistorialRoute().push(context),
                    ),
                    CardItem(
                      icon: Icons.document_scanner_rounded,
                      label: 'Reportes',
                      onTap: () {
                        AuthReportesScreenRoute().push(context);
                      },
                    ),
                    CardItem(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () {
                        GaleriaRoute().push(context);
                      },
                    ),
                    CardItem(
                      icon: Icons.point_of_sale_sharp,
                      label: 'Punto de Venta',
                      onTap: () => PuntoVentaRoute().push(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Future<dynamic> homeModalButtom(
      {required BuildContext context, required Widget child, double? height}) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Popover(
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
