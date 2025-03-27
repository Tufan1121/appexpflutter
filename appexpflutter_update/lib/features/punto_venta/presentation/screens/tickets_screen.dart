import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/upper_case_text_formatter.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/inventario_tienda/inventario_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/lista_productos_venta_copy.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/search_producto_punto_venta.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

const list = [
  'Pendiente Pago (Anticipo)',
  'Pagado Foráneo',
  'Pagado (Recoger en tienda)'
];

class TicketsScreen extends StatefulHookWidget {
  final Map<String, dynamic> data;
  const TicketsScreen({
    super.key,
    required this.data,
  });

  @override
  State<TicketsScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<TicketsScreen> {
  int getEstadoPedidoPagoId(String metodo) {
    return list.indexOf(metodo) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final dropdownValue = useState<String>(list.first);
    final productos = context.watch<ProductosTiendaBloc>().scannedProducts;
    final scrollController = useScrollController();
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<ProductosTiendaBloc>().add(ClearProductoStateEvent());
        context
            .read<InventarioTiendaBloc>()
            .add(ClearInventarioProductoEvent());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: ElevatedButton(
          onPressed: () {
            if (productos.isNotEmpty) {
              GenerarPedidoVentaRoute(
                      estadoPedido: getEstadoPedidoPagoId(dropdownValue.value),
                      $extra: widget.data)
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
                      onPressed: () {
                        context
                            .read<ProductosTiendaBloc>()
                            .add(ClearProductoStateEvent());
                        context
                            .read<InventarioTiendaBloc>()
                            .add(ClearInventarioProductoEvent());
                        Navigator.pop(context);
                      },
                      title: 'TICKETS',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Scrollbar(
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
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
                                  widget.data['nombre'],
                                  style: const TextStyle(
                                      color: Colores.secondaryColor,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                            /* const SizedBox(height: 5),
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
                            ), */
                            const SizedBox(height: 8),
                            BlocConsumer<ProductosTiendaBloc, ProductosState>(
                              listener: (context, state) {
                                if (state is ProductosLoaded) {
                                  if (state.existencia == true) {
                                    controller.clear();
                                    _showModal(
                                      context: context,
                                      icon: const Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.circleCheck,
                                          color: Colors.green,
                                          size: 40,
                                        ),
                                      ),
                                      title: 'Agregado',
                                      menssage:
                                          'El producto si esta en existencia',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }
                                } else if (state is ProductoError) {
                                  if (state.existencia == false) {
                                    controller.clear();
                                    _showModal(
                                      context: context,
                                      icon: const Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.circleXmark,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                      title: 'Error',
                                      menssage:
                                          'No existe o no está disponible',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }
                                }
                              },
                              builder: (context, state) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 2.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomSearch(
                                          controller: controller,
                                          inputFormatters: [
                                            UpperCaseTextFormatter(),
                                          ],
                                          hintText: 'Validar Clave',
                                          onSubmitted: (value) {
                                            context
                                                .read<ProductosTiendaBloc>()
                                                .add(GetProductEvent(
                                                    clave: value));
                                          },
                                          validator: (value) {
                                            final List<String>
                                                clavesNoPermitidas = [
                                              'F-MIA',
                                              'T-MIA',
                                              'Q-MIA',
                                              'A-MIA'
                                            ];
                                            if (value.isNotEmpty) {
                                              // Verificar si la clave completa está en la lista de claves no permitidas
                                              if (clavesNoPermitidas.any(
                                                  (clave) => value
                                                      .startsWith(clave))) {
                                                controller.clear();
                                                return "No puede vender esta Clave.";
                                              }
                                              // Verificar si la clave comienza con 'M'
                                              if (value.startsWith('M')) {
                                                controller.clear();
                                                return "No puede vender esta Clave.";
                                              }
                                            }
                                            // controller.clear();
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            PuntoVentaProductSearch(
                              estatusPedido:
                                  getEstadoPedidoPagoId(dropdownValue.value),
                              telefonoCliente: ' telefonoCliente ',
                            ),
                            const SizedBox(height: 5),
                            BlocBuilder<ProductosTiendaBloc, ProductosState>(
                              builder: (context, state) {
                                if (state is ProductosLoaded) {
                                  return ListaProductosVenta(
                                      productos: state.productos);
                                } else if (state is ProductoLoading) {
                                  return const Column(
                                    children: [
                                      SizedBox(height: 150),
                                      CircularProgressIndicator(
                                        color: Colores.secondaryColor,
                                      ),
                                    ],
                                  );
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

  void _showModal(
      {required BuildContext context,
      required String title,
      required String menssage,
      required VoidCallback onPressed,
      final Widget? icon}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: icon,
          title: Text(title),
          content: Text(
            menssage,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colores.secondaryColor,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colores.scaffoldBackgroundColor),
                ),
                onPressed: () {
                  // opcion 1
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
