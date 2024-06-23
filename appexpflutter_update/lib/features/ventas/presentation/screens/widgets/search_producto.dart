import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/invetario_bodega.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_producto.dart';

class SearchProducto extends HookWidget {
  const SearchProducto({
    super.key,
  });

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
        children: [
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2.0, 5.0),
                  )
                ],
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: Colores.secondaryColor,
                  fontSize: 16,
                ),
                obscureText: false,
                keyboardType: TextInputType.text,
                onChanged: (value) {},
                onSubmitted: (value) {
                  context
                      .read<ProductosBloc>()
                      .add(GetQRProductEvent(clave: value));
                  controller.clear();
                },
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: IconButton(
                      onPressed: () {
                        context
                            .read<ProductosBloc>()
                            .add(GetQRProductEvent(clave: controller.text));
                        FocusScope.of(context).unfocus();
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colores.secondaryColor,
                      ),
                    ),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.clear();
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                          ))
                      : null,
                  hintText: 'Clave Manual',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.only(left: 12.0, top: 5, bottom: 20),
                ),
              ),
            ),
          ),
          BlocBuilder<ProductosBloc, ProductosState>(
            builder: (context, state) {
              if (state is ProductosLoaded) {
                return ElevatedButton(
                  onPressed: () {
                    GenerarPedidoRoute().push(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.truck,
                    color: Colores.secondaryColor,
                    size: 35,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
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
