import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/search_producto.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lista_productos.dart';
import 'package:google_fonts/google_fonts.dart';

const list = [
  'Pendiente Pago (Anticipo)',
  'Pagado Foráneo',
  'Pagado (Recoger en tienda)'
];

class PedidoScreen extends StatefulHookWidget {
  const PedidoScreen(
      {super.key,
      required this.idCliente,
      required this.nombreCliente,
      required this.telefonoCliente});
  final int idCliente;
  final String nombreCliente;
  final String telefonoCliente;

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  int getEstadoPedidoPagoId(String metodo) {
    return list.indexOf(metodo) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownValue = useState<String>(list.first);
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
            'COTIZACION',
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
                    const SizedBox(height: 20),
                    SearchProducto(
                      estatusPedido: getEstadoPedidoPagoId(dropdownValue.value),
                      idCliente: widget.idCliente,
                      telefonoCliente: widget.telefonoCliente,
                    ),
                    const SizedBox(height: 5),
                    BlocConsumer<ProductosBloc, ProductosState>(
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
                          return ListaProductos(productos: state.productos);
                        } else if (state is ProductoLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ProductoError) {
                          return ListaProductos(
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
