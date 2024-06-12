import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PreciosScreen extends StatelessWidget {
  const PreciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Precios',
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2.0, 5.0),
            )
          ],
        ),
        child: TextFormField(
          style: const TextStyle(
            color: Colores.secondaryColor,
            fontSize: 16,
          ),
          obscureText: false,
          keyboardType: TextInputType.text,
          onChanged: (val) {},
          onTap: () {},
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.search,
                color: Colores.secondaryColor,
              ),
            ),
            hintText: 'Clave',
            hintStyle: const TextStyle(color: Colors.grey),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.only(left: 12.0, top: 20, bottom: 20),
          ),
        ),
      ),
    );
  }
}
