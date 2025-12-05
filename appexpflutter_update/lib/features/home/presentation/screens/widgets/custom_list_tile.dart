import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colores.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colores.primaryColor.withValues(alpha: 0.1),
                Colores.accentColor.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colores.primaryColor.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: assetPathIcon != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(assetPathIcon ?? '', scale: 7),
                )
              : Center(
                  child: Icon(
                    icon,
                    size: 24,
                    color: Colores.primaryColor,
                  ),
                ),
        ),
        title: Text(
          text ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colores.textPrimary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colores.primaryColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colores.primaryColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
