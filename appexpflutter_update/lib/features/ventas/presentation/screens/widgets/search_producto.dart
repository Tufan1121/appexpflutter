import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/invetario_bodega.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_producto.dart';

class SearchProducto extends HookWidget {
  const SearchProducto({
    required this.estatusPedido,
    required this.idCliente,
    super.key,
  });
  final int estatusPedido;
  final int idCliente;

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductosBloc>().scannedProducts;
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
            child: const FaIcon(
              FontAwesomeIcons.store,
              color: Colores.secondaryColor,
              size: 35,
            ),
          ),
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
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Colores.secondaryColor,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
