import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class CardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const CardItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
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
                  child: Icon(icon, size: 30, color: Colores.secondaryColor)),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
