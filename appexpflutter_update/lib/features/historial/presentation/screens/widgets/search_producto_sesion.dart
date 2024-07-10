import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/custom_list_tile.dart';
import 'package:appexpflutter_update/features/shared/widgets/modals_buttom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/invetario_bodega.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_producto.dart';

class SearchProductoSesion extends HookWidget {
  const SearchProductoSesion({
    required this.estatusPedido,
    required this.idCliente,
    super.key,
  });
  final int estatusPedido;
  final int idCliente;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final scanResult = useState<String>('');
    final textFieldValue = useState<String>('');
    final productos = context.watch<ProductosBloc>().scannedProducts;

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
                      .read<ProductosBloc>()
                      .add(GetQRProductEvent(clave: scanResult.value));

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/pedido'));
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
                  return const InventarioBodega();
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
                        CustomListTile(
                          text: 'GENERAR SESION',
                          assetPathIcon:
                              'assets/iconos/pedidos - rosa gris.png',
                          onTap: () => SesionPedidoRoute(
                                  idCliente: idCliente,
                                  estadoPedido: estatusPedido)
                              .push(context),
                        ),
                        const Divider(),
                        CustomListTile(
                          text: 'GENERAR COTIZACION',
                          assetPathIcon:
                              'assets/iconos/pedidos - rosa gris.png',
                          onTap: () => CotizaPedidoRoute(
                                  idCliente: idCliente,
                                  estadoPedido: estatusPedido)
                              .push(context),
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
