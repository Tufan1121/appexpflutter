import 'package:flutter/services.dart';

/// Impide capturar un importe mayor al máximo permitido.
///
/// El máximo se consulta en cada tecla porque depende de los otros pagos ya
/// capturados: si el pago 1 ya cubre el total, el pago 2 no admite nada.
/// Rechazar la tecla (devolver [oldValue]) es más seguro que recortar el texto:
/// el usuario nunca llega a ver en pantalla un importe que no se puede cobrar.
class LimiteImporteFormatter extends TextInputFormatter {
  const LimiteImporteFormatter(this.maximoDisponible, {this.onRechazado});

  /// Importe máximo aceptable en este campo, evaluado al momento de teclear.
  final double Function() maximoDisponible;

  /// Se invoca cuando se rechaza una captura (para avisar al usuario).
  final void Function(double maximo)? onRechazado;

  /// Tolerancia para no rechazar por redondeo de centavos.
  static const double _tolerancia = 0.01;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // El campo puede traer separadores de miles (36,980.00).
    final importe = double.tryParse(newValue.text.replaceAll(',', ''));
    // Texto intermedio que todavía no es un número (por ejemplo "1."): se deja
    // pasar, el límite se aplica en cuanto sea interpretable.
    if (importe == null) return newValue;

    final maximo = maximoDisponible();
    if (importe - maximo > _tolerancia) {
      onRechazado?.call(maximo);
      return oldValue;
    }
    return newValue;
  }
}
