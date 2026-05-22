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
          SafeArea(
            child: Column(
              children: [
                Row(
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
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      // Landscape / pantalla ancha: branding a la izquierda
                      // (ancho fijo, centrado vertical) y opciones a la
                      // derecha. Antes el logo + usuario apilados arriba
                      // ocupaban todo el alto y tapaban las opciones.
                      final landscape = c.maxWidth > c.maxHeight;
                      if (landscape) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 300,
                              child: Center(child: _buildBrand(compact: true)),
                            ),
                            Expanded(child: _buildCards(context)),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          const SizedBox(height: 5),
                          _buildBrand(),
                          const SizedBox(height: 5),
                          Expanded(child: _buildCards(context)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Logo + bienvenida. En landscape `compact` reduce el tamaño del logo.
  Widget _buildBrand({bool compact = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/tufan_logo.png',
          scale: compact ? 3.5 : 2.5,
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FutureBuilder<(String, String)>(
              future: username(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final (username, almacen) = snapshot.data!;
                  return Column(
                    children: [
                      AutoSizeText('Bienvenido $username',
                          textAlign: TextAlign.center,
                          maxLines: 2,
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
                          textAlign: TextAlign.center,
                          maxLines: 2,
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
        ),
      ],
    );
  }

  /// Grid de opciones. En pantallas anchas (landscape / tablet / desktop) se
  /// limita el ancho del grid y se usan 4 columnas para que las cards no
  /// crezcan demasiado; en portrait se mantienen 2 columnas.
  Widget _buildCards(BuildContext context) {
    final cards = <Widget>[
      _preciosCard(context),
      _cotizacionesCard(context),
      _inventariosCard(context),
      _historialCard(context),
      _galeriaCard(context),
      _puntoVentaCard(context),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final crossAxisCount = wide && cards.length >= 4 ? 4 : 2;
        final maxGridWidth = crossAxisCount == 4 ? 1000.0 : 720.0;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxGridWidth),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0, vertical: 30.0),
              children: cards,
            ),
          ),
        );
      },
    );
  }

  Widget _preciosCard(BuildContext context) {
    return CardItem(
      assetPathIcon: 'assets/iconos/qr/qr 72_.png',
      label: 'Precios',
      onTap: () => PreciosRoute().push(context),
    );
  }

  Widget _inventariosCard(BuildContext context) {
    return CardItem(
      assetPathIcon: 'assets/iconos/inventarios - rosa gris.png',
      label: 'Inventarios',
      onTap: () => homeModalButtom(
          context: context,
          height: 220,
          child: ListView(
            children: [
              CustomListTile(
                text: 'INVENTARIO TIENDA',
                assetPathIcon: 'assets/iconos/inventario expo - rosa.png',
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
                assetPathIcon: 'assets/iconos/busqueda global - rosa.png',
                onTap: () => BusquedaGlobalRoute().push(context),
              ),
            ],
          )),
    );
  }

  Widget _cotizacionesCard(BuildContext context) {
    return CardItem(
      assetPathIcon: 'assets/iconos/precios - rosa gris.png',
      label: 'Cotizaciones',
      onTap: () => homeModalButtom(
          height: 160,
          context: context,
          child: ListView(
            children: [
              CustomListTile(
                text: 'CLIENTE NUEVO',
                assetPathIcon: 'assets/iconos/cliente nuevo - rosa gris.png',
                onTap: () => ClienteNuevoRoute().push(context),
              ),
              const Divider(),
              CustomListTile(
                text: 'CLIENTE EXISTENTE',
                assetPathIcon:
                    'assets/iconos/cliente existente - rosa gris.png',
                onTap: () => ClienteExistenteRoute().push(context),
              ),
            ],
          )),
    );
  }

  Widget _historialCard(BuildContext context) {
    return CardItem(
      icon: Icons.history_rounded,
      label: 'Historial',
      onTap: () => HistorialRoute().push(context),
    );
  }

  Widget _galeriaCard(BuildContext context) {
    return CardItem(
      icon: Icons.photo_library,
      label: 'Galería',
      onTap: () {
        GaleriaRoute().push(context);
      },
    );
  }

  Widget _puntoVentaCard(BuildContext context) {
    return CardItem(
      icon: Icons.point_of_sale_sharp,
      label: 'Punto de Venta',
      onTap: () => PuntoVentaRoute().push(context),
    );
  }

  Future<dynamic> homeModalButtom(
      {required BuildContext context, required Widget child, double? height}) {
    // `isScrollControlled: true` permite que el sheet use el alto pedido
    // completo (sin él se limita a ~50% de la pantalla y en landscape
    // cortaba la 3a opción "BUSQUEDA GLOBAL"). Además acotamos a 85% del
    // alto disponible para que nunca tape la barra de estado.
    final maxH = MediaQuery.of(context).size.height * 0.85;
    final h = (height ?? 220).clamp(0.0, maxH);
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Popover(
          child: Container(
            height: h,
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
