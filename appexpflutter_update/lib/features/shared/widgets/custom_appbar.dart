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
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor == null || backgroundColor == Colors.transparent
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colores.primaryColor.withOpacity(0.95),
                  Colores.accentColor.withOpacity(0.85),
                ],
              )
            : null,
        color: backgroundColor != null && backgroundColor != Colors.transparent
            ? backgroundColor
            : null,
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onPressed != null
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: color ?? Colors.white,
                  padding: EdgeInsets.zero,
                ),
              )
            : null,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: color ?? Colors.white),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: AutoSizeText(
            title,
            style: GoogleFonts.montserratAlternates(
              fontWeight: FontWeight.w700,
              color: color ?? Colors.white,
              fontSize: 20,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            maxLines: 1,
          ),
        ),
        actions: actions,
      ),
    );
  }
}
