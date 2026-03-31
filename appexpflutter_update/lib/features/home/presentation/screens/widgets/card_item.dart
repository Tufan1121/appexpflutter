import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class CardItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final String? assetPathIcon;

  const CardItem({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.assetPathIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;
    final iconColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.3),
                          blurRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(50))),
                  child: assetPathIcon != null
                      ? Image.asset(assetPathIcon ?? '', scale: 6)
                      : Center(
                          child: Icon(icon,
                              size: 30, color: iconColor))),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: AutoSizeText(label,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface),
                      textAlign: TextAlign.center,
                      maxLines: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
