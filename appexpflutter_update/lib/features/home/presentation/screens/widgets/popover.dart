import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class Popover extends StatelessWidget {
   const Popover({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        border: Border.all(
          color: Colores.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildHandle(context), child ?? Container()],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.25,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colores.primaryColor.withValues(alpha: 0.3),
                Colores.accentColor.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
            boxShadow: [
              BoxShadow(
                color: Colores.primaryColor.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
