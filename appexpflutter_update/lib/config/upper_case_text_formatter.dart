import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // composing vacío: sin esto, los teclados con texto predictivo (Gboard)
    // re-imponen la minúscula del texto en composición y el formato "no pega".
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}