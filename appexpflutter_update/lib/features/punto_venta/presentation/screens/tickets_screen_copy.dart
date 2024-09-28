import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/lista_productos_venta.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/search_producto_punto_venta.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_dropdownbutton.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_search.dart';
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

  bool validarProductos(
      List<ProductoExpoEntity> productos, BuildContext context) {
    for (var producto in productos) {
      // Aquí puedes agregar las condiciones de validación para cada producto
      if (producto.producto1.isEmpty) {
        return false;
      }
      // Anexar la clave al evento GetProductEvent
      context
          .read<ProductosTiendaBloc>()
          .add(GetProductEvent(clave: producto.producto1));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
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
            'TICKETS',
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
            if (validarProductos(productos, context)) {
              GenerarPedidoVentaRoute(
                      estadoPedido: getEstadoPedidoPagoId(dropdownValue.value),
                      $extra: widget.data)
                  .push(context);
            } else {
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
                menssage: 'Uno o más productos no son válidos.',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            }
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
                          widget.data['nombre'],
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
                    const SizedBox(height: 8),
                    BlocConsumer<ProductosTiendaBloc, ProductosState>(
                      listener: (context, state) {
                        if (state is ProductosLoaded) {
                          if (state.existencia == true) {
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
                              menssage: 'El producto si esta en existencia',
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            );
                          }
                        } else if (state is ProductoError) {
                          if (state.existencia == false) {
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
                              menssage: 'No existe o no está disponible',
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
                                  hintText: 'Validar Clave',
                                  onSubmitted: (value) {
                                    context
                                        .read<ProductosTiendaBloc>()
                                        .add(GetProductEvent(clave: value));
                                  },
                                  validator: (value) {
                                    final List<String> clavesNoPermitidas = [
                                      'F-MIA',
                                      'T-MIA',
                                      'Q-MIA',
                                      'A-MIA'
                                    ];
                                    if (value.isNotEmpty) {
                                      // Verificar si la clave completa está en la lista de claves no permitidas
                                      if (clavesNoPermitidas.any(
                                          (clave) => value.startsWith(clave))) {
                                        return "No puede vender esta Clave.";
                                      }
                                      // Verificar si la clave comienza con 'M'
                                      if (value.startsWith('M')) {
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
                      estatusPedido: getEstadoPedidoPagoId(dropdownValue.value),
                      telefonoCliente: ' telefonoCliente ',
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
                          return ListaProductosVenta(
                              productos: state.productos);
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
