import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchHistorial extends HookWidget {
  const SearchHistorial({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 10),
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
        child: TextField(
          style: const TextStyle(
            color: Colores.secondaryColor,
            fontSize: 16,
          ),
          obscureText: false,
          keyboardType: TextInputType.text,
          onChanged: (value) {},
          onSubmitted: (value) {},
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.search,
                color: Colores.secondaryColor,
              ),
            ),
            hintText: 'Buscar pedido/cliente',
            hintStyle: const TextStyle(color: Colors.grey),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.only(left: 12.0, top: 5, bottom: 20),
          ),
        ),
      ),
    );
  }
}
