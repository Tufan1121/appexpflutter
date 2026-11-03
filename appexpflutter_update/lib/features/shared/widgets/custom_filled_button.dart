import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color? buttonColor;

  const CustomFilledButton(
      {super.key, this.onPressed, required this.text, this.buttonColor});

  @override
  Widget build(BuildContext context) {
    // Esquinas casi rectas y texto en mayúsculas espaciado (estilo limpio)
    const radius = Radius.circular(4);

    return FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: buttonColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: radius,
              bottomRight: radius,
              topLeft: radius,
            ))),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 1.5),
        ));
  }
}
