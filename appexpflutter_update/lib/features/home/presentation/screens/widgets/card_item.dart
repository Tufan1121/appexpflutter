import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Opción del menú: icono de línea delgada y etiqueta en mayúsculas con
/// letras espaciadas (estilo limpio, sin el círculo con sombra de antes).
class CardItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final String? assetPathIcon;

  const CardItem({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.assetPathIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;
    final iconColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        // Sin sombra: borde gris fino, estilo plano
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: assetPathIcon != null
                    ? Image.asset(assetPathIcon ?? '', scale: 6)
                    : Icon(icon, size: 40, color: iconColor),
              ),
              const SizedBox(height: 14),
              AutoSizeText(label.toUpperCase(),
                  style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.4,
                      color: iconColor),
                  textAlign: TextAlign.center,
                  // Encoge la letra antes que partir una palabra
                  wrapWords: false,
                  minFontSize: 9,
                  maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}
