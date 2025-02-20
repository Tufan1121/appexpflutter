import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/sesion/sesion_bloc.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/lista_detalle_productos.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/search_producto_sesion.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_dropdownbutton.dart';
import 'package:google_fonts/google_fonts.dart';

const list = [
  'Pendiente Pago (Anticipo)',
  'Pagado Foráneo',
  'Pagado (Recoger en tienda)'
];

class PedidoSesionScreen extends StatefulHookWidget {
  const PedidoSesionScreen(
      {super.key,
      required this.idCliente,
      required this.nombreCliente,
      required this.estado,
      required this.idSesion,
      required this.telefonoCliente});
  final int idCliente;
  final String nombreCliente;
  final int estado;
  final int idSesion;
  final String telefonoCliente;

  @override
  State<PedidoSesionScreen> createState() => _PedidoSesionScreenState();
}

class _PedidoSesionScreenState extends State<PedidoSesionScreen> {
  int getEstadoPedidoPagoId(String metodo) {
    return list.indexOf(metodo) + 1;
  }

  List<DetalleSesionEntity> detalleProducto = [];

  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState<String>(list[widget.estado - 1]);
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<DetalleSesionBloc>().add(ClearSesionEvent());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colores.secondaryColor.withOpacity(0.78),
            title: Text(
              'PEDIDO',
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
              ),
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<DetalleSesionBloc, SesionState>(
          builder: (context, state) {
            if (state is SesionLoaded) {
              detalleProducto = state.detalleSesion;
            }
            return ElevatedButton(
              onPressed: detalleProducto.isNotEmpty
                  ? () {
                      GenerarPedidoRoute(
                        idCliente: widget.idCliente,
                        estadoPedido:
                            getEstadoPedidoPagoId(dropdownValue.value),
                        idSesion: widget.idSesion,
                        telefonoCliente: widget.telefonoCliente,
                      ).push(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
              ),
              child: Image.asset(
                'assets/iconos/generar pedido- rosa.png',
                scale: 4.5,
              ),
            );
          },
        ),
        body: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: BackgroundPainter(),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Cliente: ',
                            style: TextStyle(
                                color: Colores.scaffoldBackgroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          AutoSizeText(
                            maxLines: 2,
                            widget.nombreCliente,
                            style: const TextStyle(
                                color: Colores.scaffoldBackgroundColor,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: CustomDropdownButton<String>(
                          value: dropdownValue.value,
                          hint: 'Selecciona Estatus del pedido',
                          styleHint: const TextStyle(fontSize: 15),
                          prefixIcon: const FaIcon(
                            FontAwesomeIcons.bagShopping,
                            color: Colores.secondaryColor,
                          ),
                          onChanged: (value) {
                            dropdownValue.value = value!;
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.diagramNext,
                            color: Colores.secondaryColor,
                          ),
                          items: list
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: AutoSizeText(
                                value,
                                style: const TextStyle(fontSize: 15),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SearchProductoSesion(
                        estatusPedido:
                            getEstadoPedidoPagoId(dropdownValue.value),
                        idCliente: widget.idCliente,
                        telefonoCliente: widget.telefonoCliente,
                      ),
                      const SizedBox(height: 5),
                      BlocBuilder<DetalleSesionBloc, SesionState>(
                        builder: (context, state) {
                          if (state is SesionLoaded) {
                            return ListaDetalleProductos(
                                productos: state.detalleSesion);
                          } else if (state is SesionLoading) {
                            return const Column(
                              children: [
                                SizedBox(height: 150),
                                CircularProgressIndicator(
                                  color: Colores.secondaryColor,
                                ),
                              ],
                            );
                          }
                          if (state is SesionError) {
                            return Column(
                              children: [
                                const SizedBox(height: 150),
                                Center(
                                  child: SizedBox(
                                    height: 60,
                                    width: 300,
                                    child: Card(
                                      child: AutoSizeText(
                                        state.message,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
