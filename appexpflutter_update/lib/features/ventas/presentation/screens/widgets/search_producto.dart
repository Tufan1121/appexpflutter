import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/custom_list_tile.dart';
import 'package:appexpflutter_update/features/shared/widgets/modals_buttom.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cotiza_pedido/cotiza_pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/pdf_viewer_pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/inventario_bodega.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_producto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProducto extends HookWidget {
  const SearchProducto({
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
    final productos = context.watch<ProductosBloc>().scannedProducts;
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colores.primaryColor.withValues(alpha: 0.1),
                  Colores.accentColor.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colores.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => ScannerProductoPage(
                  onDetect: (barcode) {
                    scanResult.value = barcode.barcodes.first.rawValue ?? '';

                    context
                        .read<ProductosBloc>()
                        .add(GetQRProductEvent(clave: scanResult.value));

                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('/pedido'));
                  },
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                elevation: 0,
              ),
              child: Image.asset(
                'assets/iconos/qr/qr 72_.png',
                scale: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colores.secondaryColor.withValues(alpha: 0.1),
                  Colores.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colores.secondaryColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (BuildContext context) {
                    return const InventarioBodega();
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                elevation: 0,
              ),
              child: Image.asset(
                'assets/iconos/inventario bodegas - rosa2.png',
                scale: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colores.secondaryColor.withValues(alpha: 0.12),
                  Colores.accentColor.withValues(alpha: 0.12),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colores.secondaryColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              if (productos.isNotEmpty) {
                Modals(
                    // ignore: use_build_context_synchronously
                    context: context,
                    height: 80,
                    child: ListView(
                      children: [
                        BlocConsumer<CotizaPedidoBloc, CotizaPedidoState>(
                          listener: (context, state) {
                            if (state is PedidoDetalleCotizaLoaded) {
                              Navigator.of(context).pop();

                              String pdfUrl =
                                  'https://tapetestufan.mx/cotiza/${prefs.getString('digsig')}/pdf/${state.pedido.pedidos}.pdf';
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
                                        'total_pagar': UtilsVenta.total.toInt(),
                                        // 'entregado': entregado,
                                        // 'id_metodopago2': metodo2,
                                        // 'id_metodopago3': metodo3.toString(),
                                      };

                                      context.read<CotizaPedidoBloc>().add(
                                          PedidoAddEvent(
                                              data: data,
                                              products: UtilsVenta
                                                  .listProductsOrder));
                                    },
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
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Atención',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colores.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Debes agregar algún producto',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colores.textSecondary,
                        ),
                      ),
                      actions: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colores.secondaryColor, Color(0xFFFF4081)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colores.secondaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Aceptar',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              elevation: 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colores.secondaryColor.withValues(alpha: 0.1),
                    Colores.accentColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Image.asset(
                'assets/iconos/pedidos - rosa gris.png',
                scale: 6,
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
