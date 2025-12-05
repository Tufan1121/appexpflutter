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
            // Gradiente de fondo moderno
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colores.primaryColor.withValues(alpha: 0.05),
                    Colores.accentColor.withValues(alpha: 0.03),
                    Colores.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
            // Imagen de fondo con overlay
            Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/fondo.png'),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colores.scaffoldBackgroundColor.withValues(alpha: 0.3),
                  ],
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colores.primaryColor.withValues(alpha: 0.1),
                            Colores.accentColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colores.primaryColor.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            color: Colores.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cliente: ',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colores.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: AutoSizeText(
                              widget.nombreCliente,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colores.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
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
