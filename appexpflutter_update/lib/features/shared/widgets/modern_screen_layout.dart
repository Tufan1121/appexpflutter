import 'package:flutter/material.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';

/// Widget wrapper que aplica el estilo consistente del login a todas las pantallas
/// Incluye el GeometricalBackground y un AppBar moderno opcional
class ModernScreenLayout extends StatelessWidget {
  final String? title;
  final Widget child;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showAppBar;
  final PreferredSizeWidget? customAppBar;

  const ModernScreenLayout({
    super.key,
    this.title,
    required this.child,
    this.onBack,
    this.actions,
    this.showAppBar = true,
    this.customAppBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? (customAppBar ??
              PreferredSize(
                preferredSize: const Size.fromHeight(56.0),
                child: CustomAppBar(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  title: title ?? '',
                  actions: actions,
                ),
              ))
          : null,
      body: GeometricalBackground(
        child: child,
      ),
    );
  }
}
