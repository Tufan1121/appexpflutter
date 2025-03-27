import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/sesion/sesion_bloc.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/mixin_products.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/invetario_bodega_sesion.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/custom_list_tile.dart';
import 'package:appexpflutter_update/features/shared/widgets/modals_buttom.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cotiza_pedido/cotiza_pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/session_pedido/sesion_pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/pdf_viewer_pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_producto.dart';

class SearchProductoSesion extends HookWidget with ProductoSesion {
  const SearchProductoSesion({
    required this.estatusPedido,
    required this.idCliente,
    required this.telefonoCliente,
    super.key,
  });
  final int estatusPedido;
  final int idCliente;
  final String telefonoCliente;
  

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final scanResult = useState<String>('');
    final textFieldValue = useState<String>('');
    final productos = context.watch<DetalleSesionBloc>().productsSesion;
    bool loading = false;

    useEffect(() {
      controller.addListener(() {
        textFieldValue.value = controller.text;
      });
      return null;
    }, [controller]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ScannerProductoPage(
                onDetect: (barcode) {
                  // / Manejar la detección de códigos de barras
                  scanResult.value = barcode.barcodes.first.rawValue ?? '';

                  context
                      .read<DetalleSesionBloc>()
                      .add(GetQRProductsEvent(clave: scanResult.value));

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/pedido_sesion'));
                },
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              // Otros estilos según sea necesario
            ),
            child: Image.asset(
              'assets/iconos/qr/qr 72_.png',
              scale: 5,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return const InventarioBodega2();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
            ),
            child: Image.asset(
              'assets/iconos/inventario bodegas - rosa2.png',
              scale: 5,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              if (productos.isNotEmpty) {
                Modals(
                    context: context,
                    height: 160,
                    child: ListView(
                      children: [
                        BlocConsumer<SesionPedidoBloc, SesionPedidoState>(
                          listener: (context, state) {
                            if (state is PedidoDetalleSesionLoaded) {
                              Navigator.of(context).pop();
                              HomeRoute().push(context);
                              context
                                  .read<ProductosBloc>()
                                  .add(ClearProductoStateEvent());
                              context
                                  .read<ProductosBloc>()
                                  .add(ClearProductoStateEvent());
                              context
                                  .read<ClienteBloc>()
                                  .add(ClearClienteStateEvent());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (state is PedidoSesionError) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is PedidoSesionLoading) {
                              loading = true;
                            } else if (state is PedidoDetalleSesionLoaded) {
                              loading = false;
                            } else if (state is PedidoSesionError) {
                              loading = false;
                            }
                            return CustomListTile(
                              text: loading ? 'GENERANDO...' : 'GENERAR SESION',
                              assetPathIcon:
                                  'assets/iconos/pedidos - rosa gris.png',
                              onTap: loading
                                  ? null
                                  : () {
                                      final data = {
                                        'id_cliente': idCliente,
                                        // 'id_metodopago': metodo1,
                                        // 'observaciones': observaciones,
                                        'estatus': estatusPedido,
                                        // 'anticipo': anticipoPago.toInt(),
                                        // 'anticipo2': anticipoPago2.toInt(),
                                        // 'anticipo3': anticipoPago3.toInt(),
                                        'total_pagar': UtilsVenta.total.toInt(),
                                        // 'entregado': entregado,
                                        // 'id_metodopago2': metodo2,
                                        // 'id_metodopago3': metodo3.toString(),
                                      };

                                      context.read<SesionPedidoBloc>().add(
                                          PedidoAddSesionEvent(
                                              data: data,
                                              products: UtilsVenta
                                                  .listProductsOrder));
                                    },
                            );
                          },
                        ),
                        const Divider(),
                        BlocConsumer<CotizaPedidoBloc, CotizaPedidoState>(
                          listener: (context, state) {
                            if (state is PedidoDetalleCotizaLoaded) {
                              Navigator.of(context).pop();

                              String pdfUrl =
                                  'https://tapetestufan.mx/expo/${state.pedido.idExpo}/pdf/${state.pedido.pedidos}.pdf';
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfViewerPedidoScreen(
                                    fileName: state.pedido.pedidos,
                                    search: 'Cotización',
                                    url: pdfUrl,
                                    userName: state.username,
                                    clientPhoneNumber: telefonoCliente,
                                  ),
                                ),
                              );
                              context
                                  .read<ProductosBloc>()
                                  .add(ClearProductoStateEvent());
                              context
                                  .read<ClienteBloc>()
                                  .add(ClearClienteStateEvent());

                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(state.message),
                              //     backgroundColor: Colors.green,
                              //   ),
                              // );
                            } else if (state is PedidoCotizaError) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is PedidoCotizaLoading) {
                              loading = true;
                            } else if (state is PedidoDetalleCotizaLoaded) {
                              loading = false;
                            } else if (state is PedidoCotizaError) {
                              loading = false;
                            }
                            return CustomListTile(
                                text: loading
                                    ? 'GENERANDO...'
                                    : 'GENERAR COTIZACION',
                                assetPathIcon:
                                    'assets/iconos/pedidos - rosa gris.png',
                                onTap: loading
                                    ? null
                                    : () {
                                        final data = {
                                          'id_cliente': idCliente,
                                          // 'id_metodopago': metodo1,
                                          // 'observaciones': observaciones,
                                          'estatus': estatusPedido,
                                          // 'anticipo': anticipoPago.toInt(),
                                          // 'anticipo2': anticipoPago2.toInt(),
                                          // 'anticipo3': anticipoPago3.toInt(),
                                          'total_pagar':
                                              UtilsVenta.total.toInt(),
                                          // 'entregado': entregado,
                                          // 'id_metodopago2': metodo2,
                                          // 'id_metodopago3': metodo3.toString(),
                                        };

                                        context.read<CotizaPedidoBloc>().add(
                                            PedidoAddEvent(
                                                data: data,
                                                products: UtilsVenta
                                                    .listProductsOrder));
                                      }

                                // onTap: () => CotizaPedidoRoute(
                                //         idCliente: idCliente,
                                //         estadoPedido: estatusPedido)
                                //     .push(context),
                                );
                          },
                        ),
                      ],
                    )).homeModalButtom();
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
                            style: TextStyle(
                                color: Colores.scaffoldBackgroundColor),
                          ),
                        )
                      ],
                    );
                  },
                );
              }
            },
            // onPressed: () => SesionPedidoRoute(
            //   idCliente: idCliente,
            //   estadoPedido: estatusPedido,
            // ).push(context),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              // Otros estilos según sea necesario
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.asset(
                'assets/iconos/pedidos - rosa gris.png',
                scale: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
