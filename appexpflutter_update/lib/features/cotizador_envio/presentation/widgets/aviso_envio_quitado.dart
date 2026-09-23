import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appexpflutter_update/config/theme/app_theme.dart';

/// Aviso centrado cuando se quita el envío cotizado porque se agregó una
/// partida o subió una cantidad (mismo aviso que cotizaciones en galería).
Future<void> mostrarAvisoEnvioQuitado(BuildContext context, String mensaje) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.local_shipping_rounded,
          color: Colores.warningColor, size: 40),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colores.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve a cotizar el envío con las partidas actuales.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colores.textSecondary),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colores.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
