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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colores.scaffoldBackgroundColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 50,
                  width: 50,
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
                  child: assetPathIcon != null
                      ? Image.asset(assetPathIcon ?? '', scale: 6)
                      : Center(
                          child: Icon(icon,
                              size: 30, color: Colores.secondaryColor))),
              const SizedBox(height: 10),
              AutoSizeText(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
