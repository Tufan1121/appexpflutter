import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/lista_productos_venta.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/search_producto_punto_venta.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_dropdownbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

const list = [
  'Pendiente Pago (Anticipo)',
  'Pagado Foráneo',
  'Pagado (Recoger en tienda)'
];

class TicketsScreen extends StatefulHookWidget {
  const TicketsScreen({
    super.key,
    this.nombreCliente,
    this.idCliente,
    this.telefonoCliente,
  });
  final int? idCliente;
  final String? nombreCliente;
  final String? telefonoCliente;

  @override
  State<TicketsScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<TicketsScreen> {
  int getEstadoPedidoPagoId(String metodo) {
    return list.indexOf(metodo) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState<String>(list.first);
    final productos = context.watch<ProductosTiendaBloc>().scannedProducts;
    return Scaffold(
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
      floatingActionButton: ElevatedButton(
        onPressed: () {
          if (productos.isNotEmpty) {
            GenerarPedidoRoute(
                    idCliente: widget.idCliente!,
                    estadoPedido: getEstadoPedidoPagoId(dropdownValue.value),
                    telefonoCliente: widget.telefonoCliente
                    !)
                .push(context);
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Atención'),
                  content: const Text('Debes agregar algún producto'),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colores.secondaryColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Aceptar',
                        style:
                            TextStyle(color: Colores.scaffoldBackgroundColor),
                      ),
                    )
                  ],
                );
              },
            );
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
        ),
        child: Image.asset(
          'assets/iconos/generar pedido- rosa.png',
          scale: 4.5,
        ),
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
                          widget.nombreCliente??  ''
                           ,
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
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
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
                    PuntoVentaProductSearch(
                      estatusPedido: getEstadoPedidoPagoId(dropdownValue.value),
                      telefonoCliente: widget.telefonoCliente ?? '',
                    ),
                    const SizedBox(height: 5),
                    BlocConsumer<ProductosTiendaBloc, ProductosState>(
                      listener: (context, state) {
                        if (state is ProductoError) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              state.message,
                            ),
                          ));
                        }
                      },
                      builder: (context, state) {
                        if (state is ProductosLoaded) {
                          return ListaProductosVenta(productos: state.productos);
                        } else if (state is ProductoLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ProductoError) {
                          return ListaProductosVenta(
                            productos: state.productos,
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
