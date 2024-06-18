import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    this.text,
    this.onTap,
    this.icon,
  });
  final String? text;
  final VoidCallback? onTap;
  final IconData? icon;

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
        child: Center(
          child: FaIcon(
            icon,
            color: Colores.secondaryColor,
            size: 20,
          ),
        ),
      ),
      title: Text(
        text ?? '',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }
}