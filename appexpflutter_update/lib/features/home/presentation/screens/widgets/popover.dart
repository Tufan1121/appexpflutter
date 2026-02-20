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
        borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colores.gradientEnd.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, -15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(context),
          child ?? Container(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Center(
        child: Container(
          width: 48,
          height: 5.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colores.gradientStart,
                Colores.gradientEnd,
              ],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}

