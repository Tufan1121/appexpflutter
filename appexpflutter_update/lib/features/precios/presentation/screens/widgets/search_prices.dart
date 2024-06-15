import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/scanner_dialog.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPrices extends StatelessWidget {
  const SearchPrices({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ScannerDialog(
                child: ScannerPage(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(
                  8), // padding para cambiar el tamaño del botón Fondo del botón
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
