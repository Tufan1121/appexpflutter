import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lada_pais_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Manda el pedido por WhatsApp desde el número de expo y avisa el resultado
/// en [messenger]. Si el cliente no tiene teléfono (o es inválido) pide
/// capturarlo con [dialogContext], reintenta y lo guarda en el cliente.
///
/// [dialogContext] debe seguir montado mientras dura el envío: si la pantalla
/// que llama navega enseguida, pasar el del Navigator raíz.
Future<void> enviarPedidoWhatsApp({
  required BuildContext dialogContext,
  required ScaffoldMessengerState messenger,
  required String pedidos,
  int? idExpo,
}) async {
  final dataSource = GetIt.instance<PedidoDataSource>();
  String? motivo;
  try {
    await dataSource.enviarPedidoWhatsapp(pedidos: pedidos, idExpo: idExpo);
    _aviso(messenger, 'Pedido $pedidos enviado', Colors.green);
    return;
  } on TelefonoClienteException catch (e) {
    motivo = e.message;
  } catch (e) {
    _avisoError(messenger, pedidos, e);
    return;
  }

  if (!dialogContext.mounted) return;
  final capturado = await _capturarTelefono(dialogContext, pedidos, motivo);
  if (capturado == null) return;

  try {
    await dataSource.enviarPedidoWhatsapp(
      pedidos: pedidos,
      idExpo: idExpo,
      telefono: capturado.telefono,
      ladaPais: capturado.lada,
      guardar: true,
    );
    _aviso(messenger, 'Pedido $pedidos enviado', Colors.green);
  } catch (e) {
    _avisoError(messenger, pedidos, e);
  }
}

void _aviso(ScaffoldMessengerState messenger, String texto, Color color) {
  messenger.showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
}

void _avisoError(ScaffoldMessengerState messenger, String pedidos, Object e) {
  messenger.showSnackBar(
    SnackBar(
      content: Text(
          'Error al enviar WhatsApp del pedido $pedidos: ${e.toString().replaceFirst('Exception: ', '')}'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 6),
    ),
  );
}

typedef _TelefonoCapturado = ({String lada, String telefono});

Future<_TelefonoCapturado?> _capturarTelefono(
    BuildContext context, String pedidos, String motivo) {
  final form = FormGroup({
    'lada_pais': FormControl<String>(value: ladaMexico),
    'telefono': FormControl<String>(validators: [Validators.required]),
  });

  void aceptar(BuildContext dialog) {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }
    if (!telefonoValido(form)) return;
    Navigator.of(dialog).pop((
      lada: form.control('lada_pais').value as String? ?? ladaMexico,
      telefono: form.control('telefono').value as String,
    ));
  }

  return showDialog<_TelefonoCapturado>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Teléfono del cliente'),
      content: ReactiveForm(
        formGroup: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              motivo.contains('no tiene')
                  ? 'El cliente del pedido $pedidos no tiene teléfono. '
                      'Captúralo para enviarle el pedido; se guardará en el cliente.'
                  : 'El teléfono del cliente del pedido $pedidos no es válido. '
                      'Captúralo de nuevo; se guardará en el cliente.',
            ),
            const SizedBox(height: 16),
            CustomReactiveTextField(
              formControlName: 'telefono',
              label: 'Telefono/WhatsApp',
              keyboardType: TextInputType.phone,
              prefixIcon: const LadaPaisSelector(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              validationMessages: telefonoValidationMessages,
              onSubmitted: (_) => aceptar(dialog),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => aceptar(dialog),
          child: const Text('Enviar'),
        ),
      ],
    ),
  );
}
