import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget {
  final Function()? onPressed;
  final String title;
  final List<Widget>? actions;
  final Color? color;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.onPressed,
    required this.title,
    this.actions,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      iconTheme: IconThemeData(color: color ?? Colors.white),
      backgroundColor:
          backgroundColor ?? Colores.secondaryColor.withOpacity(0.9),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: AutoSizeText(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: color ?? Colores.scaffoldBackgroundColor,
            shadows: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 6,
                offset: Offset(2.0, 2.0),
              )
            ],
          ),
          maxLines: 1,
        ),
      ),
      actions: actions,
    );
  }
}
