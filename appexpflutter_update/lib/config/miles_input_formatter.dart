import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Da formato de miles en vivo a un campo de importe: al teclear 36980
/// se ve 36,980 (patrón 99,999,999.99: hasta 8 enteros y 2 decimales).
class MilesInputFormatter extends TextInputFormatter {
  const MilesInputFormatter();

  static final RegExp _patron = RegExp(r'^\d{0,8}(\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) {
      return newValue.copyWith(text: '');
    }
    // Solo dígitos y un punto con hasta 2 decimales; lo demás se rechaza.
    if (!_patron.hasMatch(raw)) return oldValue;

    final partes = raw.split('.');
    final enteros = partes[0];
    final buffer = StringBuffer();
    for (var i = 0; i < enteros.length; i++) {
      if (i > 0 && (enteros.length - i) % 3 == 0) buffer.write(',');
      buffer.write(enteros[i]);
    }
    final texto = partes.length > 1
        ? '${buffer.toString()}.${partes[1]}'
        : buffer.toString();
    return TextEditingValue(
      text: texto,
      // En campos de dinero el cursor al final es lo esperado.
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// Traductor entre el texto con comas del campo y el `double` del FormControl.
/// Al pre-llenar programáticamente (pago con tarjeta) muestra 36,980.00.
class MilesValueAccessor extends ControlValueAccessor<double, String> {
  static final NumberFormat _fmt = NumberFormat('#,##0.00', 'en_US');

  @override
  String modelToViewValue(double? modelValue) =>
      modelValue == null ? '' : _fmt.format(modelValue);

  @override
  double? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.trim().isEmpty) return null;
    return double.tryParse(viewValue.replaceAll(',', ''));
  }
}
