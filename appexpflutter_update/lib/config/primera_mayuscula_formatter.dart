import 'package:flutter/services.dart';

/// Fuerza que la primera letra del texto sea mayúscula.
///
/// `textCapitalization: sentences` solo lo sugiere en el teclado en pantalla;
/// este formatter lo garantiza aunque el usuario apague el shift o use
/// teclado físico. El resto del texto se respeta tal cual.
class PrimeraMayusculaFormatter extends TextInputFormatter {
  const PrimeraMayusculaFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final capitalizado = text[0].toUpperCase() + text.substring(1);
    if (capitalizado == text) return newValue;
    return newValue.copyWith(
      text: capitalizado,
      selection: newValue.selection,
    );
  }
}
