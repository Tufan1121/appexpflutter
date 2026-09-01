import 'package:appexpflutter_update/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/widgets.dart';
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  // Encabezado compacto en una sola fila (logo + usuario +
                  // salir) para dejarle el espacio al grid de opciones.
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo_tufan.png',
                          scale: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Usuario y almacén
                      Expanded(
                        child: FutureBuilder<(String, String)>(
                          future: username(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              );
                            }
                            final (username, almacen) = snapshot.data ?? ('', '');
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '¡Bienvenido, $username!',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Almacén: $almacen',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Cerrar sesión
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
                            size: 22,
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
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 4 columnas en desktop/tablet ancho, 3 en tablet medio,
                    // 2 en phone. Cap del grid a 1100 px para que en pantallas
                    // anchas las cards no queden gigantes.
                    final w = constraints.maxWidth;
                    final crossAxisCount = w >= 1100
                        ? 4
                        : w >= 800
                            ? 3
                            : 2;
                    final maxGridWidth = crossAxisCount == 4
                        ? 1100.0
                        : crossAxisCount == 3
                            ? 850.0
                            : double.infinity;
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxGridWidth),
                        child: GridView.count(
                  crossAxisCount: crossAxisCount,
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
                    CardItem(
                      icon: Icons.local_shipping_rounded,
                      label: 'Cotizador de Envíos',
                      onTap: () => CotizadorEnvioRoute().push(context),
                    ),
                  ],
                ),
                      ),
                    );
                  },
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
