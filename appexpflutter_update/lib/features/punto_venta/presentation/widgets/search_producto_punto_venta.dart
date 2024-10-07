import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/inventario_tienda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_producto.dart';

class PuntoVentaProductSearch extends HookWidget {
  const PuntoVentaProductSearch({
    required this.estatusPedido,
    required this.telefonoCliente,
    super.key,
  });
  final int estatusPedido;
  final String telefonoCliente;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final scanResult = useState<String>('');
    final textFieldValue = useState<String>('');

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
                      .read<ProductosTiendaBloc>()
                      .add(GetQRProductEvent(clave: scanResult.value));

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/tickets'));
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
                  return const InventarioTienda();
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
        ],
      ),
    );
  }
}
