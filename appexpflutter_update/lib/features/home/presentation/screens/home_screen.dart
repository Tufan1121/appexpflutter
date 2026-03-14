import 'package:appexpflutter_update/config/config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/widgets.dart';
import 'package:appexpflutter_update/features/shared/widgets/modern_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      body: Stack(
        children: [
          // Gradiente de fondo moderno
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colores.primaryColor.withOpacity(0.1),
                  Colores.accentColor.withOpacity(0.05),
                  Colores.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          // Imagen de fondo con overlay
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/fondo.png',
                ),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colores.scaffoldBackgroundColor.withOpacity(0.3),
                ],
              ),
            ),
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
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colores.primaryColor.withOpacity(0.9),
                                Colores.accentColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colores.primaryColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                context.read<AuthBloc>().add(const LogoutEvent());
                                LoginRoute().go(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/tufan_logo.png',
                            scale: 2.5,
                          ),
                          const SizedBox(height: 5),
                          FutureBuilder<(String, String)>(
                              future: username(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  final (username, almacen) = snapshot.data!;
                                  return Column(
                                    children: [
                                      AutoSizeText('Bienvenido $username',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            shadows: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(2.0, 5.0),
                                              )
                                            ],
                                          )),
                                      AutoSizeText('Almacen: $almacen',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            color: Colores.secondaryColor
                                                .withOpacity(0.8),
                                            shadows: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(2.0, 5.0),
                                              )
                                            ],
                                          )),
                                    ],
                                  );
                                } else {
                                  return const Text('No data');
                                }
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    ModernItemCard(
                      assetPathIcon: 'assets/iconos/qr/qr 72_.png',
                      label: 'Precios',
                      onTap: () => PreciosRoute().push(context),
                      gradientColors: [
                        Colores.primaryColor.withOpacity(0.1),
                        Colores.accentColor.withOpacity(0.05),
                      ],
                    ),
                    ModernItemCard(
                      assetPathIcon: 'assets/iconos/precios - rosa gris.png',
                      label: 'Cotizaciones',
                      onTap: () => homeModalButtom(
                          height: 160,
                          context: context,
                          child: ListView(
                            children: [
                              CustomListTile(
                                text: 'CLIENTE NUEVO',
                                assetPathIcon:
                                    'assets/iconos/cliente nuevo - rosa gris.png',
                                onTap: () => ClienteNuevoRoute().push(context),
                              ),
                              const Divider(),
                              CustomListTile(
                                text: 'CLIENTE EXISTENTE',
                                assetPathIcon:
                                    'assets/iconos/cliente existente - rosa gris.png',
                                onTap: () =>
                                    ClienteExistenteRoute().push(context),
                              ),
                            ],
                          )),
                    ),
                    ModernItemCard(
                      assetPathIcon:
                          'assets/iconos/inventarios - rosa gris.png',
                      label: 'Inventarios',
                      gradientColors: [
                        Colores.accentColor.withOpacity(0.1),
                        Colores.primaryColor.withOpacity(0.05),
                      ],
                      onTap: () => homeModalButtom(
                          context: context,
                          height: 220,
                          child: ListView(
                            children: [
                              CustomListTile(
                                text: 'INVENTARIO TIENDA',
                                assetPathIcon:
                                    'assets/iconos/inventario expo - rosa.png',
                                onTap: () => InvetarioExpoRoute().push(context),
                              ),
                              const Divider(),
                              CustomListTile(
                                  text: 'INVENTARIO BODEGAS',
                                  assetPathIcon:
                                      'assets/iconos/inventario bodegas - rosa2.png',
                                  onTap: () {
                                    InvetarioBodegaRoute().push(context);
                                  }),
                              const Divider(),
                              CustomListTile(
                                text: 'BUSQUEDA GLOBAL',
                                assetPathIcon:
                                    'assets/iconos/busqueda global - rosa.png',
                                onTap: () =>
                                    BusquedaGlobalRoute().push(context),
                              ),
                            ],
                          )),
                    ),
                    ModernItemCard(
                      icon: Icons.history_rounded,
                      label: 'Historial',
                      onTap: () => HistorialRoute().push(context),
                      gradientColors: [
                        Colores.secondaryColor.withOpacity(0.1),
                        Colores.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    ModernItemCard(
                      icon: Icons.photo_library_rounded,
                      label: 'Galería',
                      onTap: () {
                        GaleriaRoute().push(context);
                      },
                      gradientColors: [
                        Colores.accentColor.withOpacity(0.1),
                        Colores.secondaryColor.withOpacity(0.05),
                      ],
                    ),
                    ModernItemCard(
                      icon: Icons.point_of_sale_rounded,
                      label: 'Punto de Venta',
                      onTap: () => PuntoVentaRoute().push(context),
                      gradientColors: [
                        Colores.primaryColor.withOpacity(0.1),
                        Colores.secondaryColor.withOpacity(0.05),
                      ],
                    ),
                    ModernItemCard(
                      icon: Icons.local_shipping_rounded,
                      label: 'Cotizador de Envíos',
                      onTap: () => CotizadorEnvioRoute().push(context),
                      gradientColors: [
                        Colores.secondaryColor.withOpacity(0.1),
                        Colores.accentColor.withOpacity(0.05),
                      ],
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

  Future<dynamic> homeModalButtom(
      {required BuildContext context, required Widget child, double? height}) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          child: Container(
            height: height,
            color: Colores.scaffoldBackgroundColor,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
