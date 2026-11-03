import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// País para la clave internacional del teléfono del cliente (clientes.lada_pais).
/// El backend la usa para mandar el WhatsApp del pedido; sin ella supone México.
class PaisLada {
  final String lada;
  final String bandera;
  final String nombre;

  /// Dígitos del número local; 0 = no se valida la longitud exacta.
  final int digitos;

  const PaisLada(this.lada, this.bandera, this.nombre, this.digitos);
}

const ladaMexico = '52';

const paisesLada = [
  PaisLada('52', '🇲🇽', 'México', 10),
  PaisLada('1', '🇺🇸', 'EE. UU. / Canadá', 10),
  PaisLada('502', '🇬🇹', 'Guatemala', 8),
  PaisLada('503', '🇸🇻', 'El Salvador', 8),
  PaisLada('57', '🇨🇴', 'Colombia', 10),
  PaisLada('34', '🇪🇸', 'España', 9),
];

/// País de una clave guardada; si no está en la lista se muestra tal cual
/// (no se cambia a México para no pisarla al editar).
PaisLada paisDeLada(String? lada) {
  final clave = (lada ?? '').trim().isEmpty ? ladaMexico : lada!.trim();
  return paisesLada.firstWhere((p) => p.lada == clave,
      orElse: () => PaisLada(clave, '🌐', '+$clave', 0));
}

/// Mensaje de error del teléfono según el país, o null si es válido.
String? validaTelefono(String? lada, String? telefono) {
  final digitos = (telefono ?? '').replaceAll(RegExp(r'\D'), '');
  final pais = paisDeLada(lada);
  if (digitos.isEmpty) return 'Captura el teléfono';
  if (pais.digitos > 0 && digitos.length != pais.digitos) {
    return 'El teléfono de ${pais.nombre} debe tener ${pais.digitos} dígitos';
  }
  if (pais.digitos == 0 && (digitos.length < 6 || digitos.length > 15)) {
    return 'Teléfono inválido';
  }
  return null;
}

/// Revisa el teléfono contra el país antes de guardar; si no cuadra, marca el
/// error en el control 'telefono' (mensaje en la llave 'telefonoPais').
bool telefonoValido(FormGroup form) {
  final error = validaTelefono(
      form.control('lada_pais').value as String?,
      form.control('telefono').value as String?);
  if (error == null) return true;
  form.control('telefono')
    ..setErrors({'telefonoPais': error})
    ..markAsTouched();
  return false;
}

/// Mensajes de validación del teléfono para CustomReactiveTextField.
final telefonoValidationMessages = <String, String Function(Object)>{
  ValidationMessage.required: (error) => 'Este campo es requerido',
  'telefonoPais': (error) => error as String,
};

/// Selector compacto (bandera + clave) ligado al control [formControlName]
/// del ReactiveForm que lo contiene. Pensado como prefixIcon del teléfono.
class LadaPaisSelector extends StatelessWidget {
  const LadaPaisSelector({super.key, this.formControlName = 'lada_pais'});

  final String formControlName;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final actual = paisDeLada(control.value);
        return PopupMenuButton<String>(
          tooltip: 'País del teléfono',
          initialValue: actual.lada,
          onSelected: (lada) => control.value = lada,
          itemBuilder: (context) => [
            for (final p in paisesLada)
              PopupMenuItem(
                value: p.lada,
                child: Text('${p.bandera}  ${p.nombre}  +${p.lada}'),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${actual.bandera} +${actual.lada}',
                    style: const TextStyle(fontSize: 15)),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
