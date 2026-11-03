import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    final theme = Theme.of(context);
    return AppBar(
      leading: IconButton(
        onPressed: onPressed,
        icon: const Icon(PhosphorIconsLight.caretLeft),
      ),
      iconTheme: IconThemeData(color: color ?? theme.colorScheme.onPrimary),
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primary,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: AutoSizeText(
          title.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
            color: color ?? theme.colorScheme.onPrimary,
          ),
          maxLines: 1,
        ),
      ),
      actions: actions,
    );
  }
}
