import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/galeria/galeria_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> username() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

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
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo_tufan.png',
                            scale: 12,
                          ),
                          const SizedBox(height: 5),
                          FutureBuilder<String>(
                              future: username(),
                              builder: (context, snapshot) {
                                return Text('Bienvenido ${snapshot.data}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colores.scaffoldBackgroundColor,
                                      shadows: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(2.0, 5.0),
                                        )
                                      ],
                                    ));
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                      assetPathIcon: 'assets/iconos/qr/qr 72_.png',
                      label: 'Precios',
                      onTap: () => PreciosRoute().push(context),
                    ),
                    CardItem(
                      assetPathIcon: 'assets/iconos/precios - rosa gris.png',
                      label: 'Nueva Sesión de Ventas',
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
                                text: 'INVENTARIO EXPO',
                                assetPathIcon:
                                    'assets/iconos/inventario expo - rosa.png',
                                onTap: () => InvetarioExpoRoute().push(context),
                              ),
                              const Divider(),
                              CustomListTile(
                                text: 'INVENTARIO BODEGAS',
                                assetPathIcon:
                                    'assets/iconos/inventario bodegas - rosa2.png',
                                onTap: () =>
                                    InvetarioBodegaRoute().push(context),
                              ),
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
                      icon: Icons.document_scanner_rounded,
                      label: 'Reportes',
                      onTap: () {
                        // ReportesScreenRoute().push(context);
                        AuthReportesScreenRoute().push(context);
                      },
                    ),
                    CardItem(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () {
                        context.read<GaleriaBloc>().add(const GetGaleriaEvent());
                        GaleriaRoute().push(context);
                      },
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
