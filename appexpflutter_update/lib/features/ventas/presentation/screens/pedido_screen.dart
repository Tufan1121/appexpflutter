import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/search_producto.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lista_productos.dart';

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

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus
          ?.unfocus(), // Para cerrar el teclado al hacer tap
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Permitir que la pantalla se ajuste cuando el teclado esté visible
        body: Stack(
          children: [
            // Imagen de fondo
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fondo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: const Size.fromHeight(40.0),
                    child: CustomAppBar(
                      backgroundColor: Colors.transparent,
                      color: Colores.secondaryColor,
                      onPressed: () => Navigator.pop(context),
                      title: 'COTIZACIÓN',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Cliente: ',
                                style: TextStyle(
                                    color: Colores.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              AutoSizeText(
                                maxLines: 2,
                                widget.nombreCliente,
                                style: const TextStyle(
                                    color: Colores.secondaryColor,
                                    fontSize: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Buscador de productos
                          SearchProducto(
                            estatusPedido:
                                getEstadoPedidoPagoId(dropdownValue.value),
                            idCliente: widget.idCliente,
                            telefonoCliente: widget.telefonoCliente,
                          ),
                          const SizedBox(height: 5),
                          // Lista de productos
                          BlocConsumer<ProductosBloc, ProductosState>(
                            listener: (context, state) {
                              if (state is ProductoError) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(state.message),
                                ));
                              }
                            },
                            builder: (context, state) {
                              if (state is ProductosLoaded) {
                                return ListaProductos(
                                    productos: state.productos);
                              } else if (state is ProductoLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is ProductoError) {
                                return ListaProductos(
                                  productos: state.productos,
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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
