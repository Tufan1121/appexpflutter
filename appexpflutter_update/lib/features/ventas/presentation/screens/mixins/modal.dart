import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/cliente_form_edit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

mixin Modal {
  Future<void> modalEditarCliente(
      Size size, BuildContext context, ClienteEntity cliente) {
    FocusScope.of(context).unfocus();
    return showDialog(
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close))
              ],
            ),
            Center(
                child: Text(
              'Editar Cliente',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colores.secondaryColor,
                  shadows: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2.0, 5.0),
                    )
                  ]),
            )),
          ],
        ),
        content: SizedBox(
          height: 470,
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: size.height * 0.60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Flexible(
                        flex: 1,
                        child: ClienteFormEdit(
                          cliente: cliente,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      context: context,
    );
  }
}
