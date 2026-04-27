import 'package:appexpflutter_update/config/config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/widgets.dart';
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.4, 0.7],
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            size: 28,
                          ),
                          tooltip: 'Cambiar tema',
                          color: Colors.white,
                          onPressed: () {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            size: 30,
                          ),
                          tooltip: 'Cerrar Sesión',
                          color: Colors.white,
                          onPressed: () {
                            context.read<AuthBloc>().add(const LogoutEvent());
                            LoginRoute().go(context);
                          },
                        )
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
                                            color: Colors.white,
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
                                            color: Colors.white70,
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
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 30.0),
                  children: [
                    CardItem(
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
                    CardItem(
                      assetPathIcon:
                          'assets/iconos/inventarios - rosa gris.png',
                      label: 'Inventarios',
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
                    CardItem(
                      icon: Icons.history_rounded,
                      label: 'Historial',
                      onTap: () => HistorialRoute().push(context),
                    ),
                    CardItem(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () {
                        GaleriaRoute().push(context);
                      },
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
            color: Theme.of(context).colorScheme.surface,
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
