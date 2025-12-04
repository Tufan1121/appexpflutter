import 'package:appexpflutter_update/config/theme/app_theme.dart';
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
                        .read<ProductosTiendaBloc>()
                        .add(GetQRProductEvent(clave: scanResult.value));

                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('/tickets'));
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
                    return const InventarioTienda();
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
        ],
      ),
    );
  }
}
