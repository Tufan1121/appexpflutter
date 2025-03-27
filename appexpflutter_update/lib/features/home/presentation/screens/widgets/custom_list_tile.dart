import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile( {
    super.key,
    this.text,
    this.onTap,
    this.icon,
    this.assetPathIcon,
  });
  final String? text;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? assetPathIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          height: 40,
          width: 40,
          decoration: const BoxDecoration(
              color: Colores.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,

                  blurRadius: 1,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(50))),
          child: assetPathIcon != null
              ? Image.asset(assetPathIcon ?? '', scale: 7)
              : Center(
                  child: Icon(icon, size: 20, color: Colores.secondaryColor))),
      title: Text(
        text ?? '',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }
}
