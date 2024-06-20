import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomSearch extends StatelessWidget {
  const CustomSearch({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.controller,
  });
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? hintText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.search,
              color: Colores.secondaryColor,
            ),
          ),
          hintText: hintText ?? 'Buscar...',
          hintStyle: const TextStyle(color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.only(left: 12.0, top: 5, bottom: 20),
        ),
      ),
    );
  }
}
