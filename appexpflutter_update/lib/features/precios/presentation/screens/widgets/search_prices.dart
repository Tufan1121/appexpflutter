import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/scanner_page_precios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchPrices extends HookWidget {
  const SearchPrices({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scanResult = useState<String>('');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
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
                style: const TextStyle(
                  color: Colores.secondaryColor,
                  fontSize: 16,
                ),
                obscureText: false,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  context
                      .read<PreciosBloc>()
                      .add(GetProductEvent(clave: value));
                },
                onSubmitted: (value) => context
                    .read<PreciosBloc>()
                    .add(GetProductEvent(clave: value)),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.search,
                      color: Colores.secondaryColor,
                    ),
                  ),
                  hintText: 'Clave',
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
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ScannerPrecioPage(
                  onDetect: (barcode) {
                    // Manejar la detección de códigos de barras aquí
                    scanResult.value = barcode.barcodes.first.rawValue ?? '';

                    context
                        .read<PreciosBloc>()
                        .add(GetQRProductEvent(clave: scanResult.value));

                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('/precios'));
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              // Estilos adicionales según sea necesario
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.asset(
                'assets/iconos/qr/qr 72_.png',
                scale: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
