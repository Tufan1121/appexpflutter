import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppBar moderno con efecto glassmorphism
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool enableGlass;
  final bool showBackButton;

  const ModernAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.enableGlass = true,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: enableGlass
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colores.primaryColor.withOpacity(0.95),
                  Colores.accentColor.withOpacity(0.85),
                ],
              ),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        child: enableGlass
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: _buildAppBarContent(context),
              )
            : _buildAppBarContent(context),
      ),
    );
  }

  Widget _buildAppBarContent(BuildContext context) {
    return AppBar(
      backgroundColor: enableGlass
          ? Colors.white.withOpacity(0.8)
          : Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enableGlass
                    ? Colores.primaryColor.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: enableGlass
                      ? Colores.primaryColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: onBackPressed ?? () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: enableGlass ? Colores.primaryColor : Colors.white,
                ),
                padding: EdgeInsets.zero,
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GoogleFonts.montserratAlternates(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: enableGlass ? Colores.textPrimary : Colors.white,
          letterSpacing: 0.5,
          shadows: enableGlass
              ? null
              : [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
      ),
      actions: actions,
    );
  }
}

/// AppBar personalizado con más control
class ModernCustomAppBar extends StatelessWidget {
  final Function()? onPressed;
  final String title;
  final List<Widget>? actions;
  final Color? color;
  final bool useGradient;

  const ModernCustomAppBar({
    super.key,
    this.onPressed,
    required this.title,
    this.actions,
    this.color,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: useGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colores.primaryColor.withOpacity(0.95),
                  Colores.accentColor.withOpacity(0.85),
                ],
              )
            : null,
        color: useGradient ? null : (color ?? Colores.primaryColor),
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
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: GoogleFonts.montserratAlternates(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
        actions: actions,
      ),
    );
  }
}
