import 'package:flutter/material.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_v.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/scanner_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/widgets.dart' show CustomSearch;

class SearchProducto extends StatelessWidget {
  const SearchProducto({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                  color: Colores.secondaryColor,
                  fontSize: 16,
                ),
                obscureText: false,
                keyboardType: TextInputType.text,
                onChanged: (value) {},
                onSubmitted: (value) {},
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.search,
                      color: Colores.secondaryColor,
                    ),
                  ),
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
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.71, // Altura inicial del modal
                    minChildSize: 0.5, // Altura mínima del modal
                    maxChildSize: 0.9, // Altura máxima del modal
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Barra indicativa para cerrar el modal
                            Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colores.secondaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                                child: Text(
                              'INVENTARIO EN BODEGAS',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colores.secondaryColor,
                                  shadows: [
                                    const BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(2.0, 5.0),
                                    )
                                  ]),
                            )),
                            const SizedBox(
                                height:
                                    10), // Espacio entre la barra y el resto del contenido
                            CustomSearch(
                              hintText: 'Calidad',
                              onChanged: (value) {},
                              onSubmitted: (value) {},
                              // Otros widgets aquí
                            )
                          ],
                        ),
                      );
                    },
                  );
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
              builder: (context) => ScannerDialog(
                child: ScannerPagev(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
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
