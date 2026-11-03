import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Renglón de submenú: icono de línea delgada y texto en mayúsculas con
/// letras espaciadas.
class CustomListTile extends StatelessWidget {
  const CustomListTile( {
    super.key,
    this.text,
    this.onTap,
    this.icon,
    this.assetPathIcon,
    this.flecha = false,
  });
  final String? text;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? assetPathIcon;
  // Flecha ">" a la derecha, para opciones que abren otra pantalla.
  final bool flecha;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: SizedBox(
          height: 40,
          width: 40,
          child: assetPathIcon != null
              ? Image.asset(assetPathIcon ?? '', scale: 7)
              : Center(child: Icon(icon, size: 26, color: color))),
      title: Text(
        (text ?? '').toUpperCase(),
        style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400, letterSpacing: 1.3, color: color),
      ),
      trailing: flecha
          ? Icon(PhosphorIconsLight.caretRight, color: color.withValues(alpha: 0.6))
          : null,
      onTap: onTap,
    );
  }
}
