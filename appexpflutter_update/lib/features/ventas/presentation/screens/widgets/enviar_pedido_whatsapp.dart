import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lada_pais_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Manda el pedido (o la cotización, con [cotizacion]) por WhatsApp desde el
/// número de expo y avisa el resultado en [messenger]. Si el cliente no tiene
/// teléfono (o es inválido) pide capturarlo con [dialogContext], reintenta y
/// lo guarda en el cliente.
///
/// [dialogContext] debe seguir montado mientras dura el envío: si la pantalla
/// que llama navega enseguida, pasar el del Navigator raíz.
Future<void> enviarPedidoWhatsApp({
  required BuildContext dialogContext,
  required ScaffoldMessengerState messenger,
  required String pedidos,
  int? idExpo,
  bool cotizacion = false,
}) async {
  final dataSource = GetIt.instance<PedidoDataSource>();
  final documento = cotizacion ? 'la cotización' : 'el pedido';
  final enviado =
      cotizacion ? 'Cotización $pedidos enviada' : 'Pedido $pedidos enviado';
  String? motivo;
  try {
    await dataSource.enviarPedidoWhatsapp(
        pedidos: pedidos, idExpo: idExpo, cotizacion: cotizacion);
    _aviso(messenger, enviado, Colors.green);
    return;
  } on TelefonoClienteException catch (e) {
    motivo = e.message;
  } catch (e) {
    _avisoError(messenger, '$documento $pedidos', e);
    return;
  }

  if (!dialogContext.mounted) return;
  final capturado =
      await _capturarTelefono(dialogContext, '$documento $pedidos', motivo);
  if (capturado == null) return;

  try {
    await dataSource.enviarPedidoWhatsapp(
      pedidos: pedidos,
      idExpo: idExpo,
      telefono: capturado.telefono,
      ladaPais: capturado.lada,
      guardar: true,
      cotizacion: cotizacion,
    );
    _aviso(messenger, enviado, Colors.green);
  } catch (e) {
    _avisoError(messenger, '$documento $pedidos', e);
  }
}

void _aviso(ScaffoldMessengerState messenger, String texto, Color color) {
  messenger.showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
}

/// [documento]: "el pedido P123" / "la cotización C45".
void _avisoError(ScaffoldMessengerState messenger, String documento, Object e,
    {String medio = 'WhatsApp'}) {
  messenger.showSnackBar(
    SnackBar(
      content: Text(
          'Error al enviar por $medio $documento: ${e.toString().replaceFirst('Exception: ', '')}'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 6),
    ),
  );
}

typedef _TelefonoCapturado = ({String lada, String telefono});

Future<_TelefonoCapturado?> _capturarTelefono(
    BuildContext context, String documento, String motivo) {
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

  // "el pedido P123" -> "del pedido P123"
  final delDocumento = documento.startsWith('el ')
      ? 'del ${documento.substring(3)}'
      : 'de $documento';

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
                  ? 'El cliente $delDocumento no tiene teléfono. '
                      'Captúralo para enviárselo; se guardará en el cliente.'
                  : 'El teléfono del cliente $delDocumento no es válido. '
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

/// Manda el pedido (o la cotización) por correo con el PDF adjunto. Si el
/// cliente no tiene correo (o es inválido) pide capturarlo, reintenta y lo
/// guarda en el cliente. Mismas reglas de [dialogContext] que el WhatsApp.
Future<void> enviarPedidoCorreo({
  required BuildContext dialogContext,
  required ScaffoldMessengerState messenger,
  required String pedidos,
  int? idExpo,
  bool cotizacion = false,
}) async {
  final dataSource = GetIt.instance<PedidoDataSource>();
  final documento = cotizacion ? 'la cotización' : 'el pedido';
  final enviado = cotizacion
      ? 'Cotización $pedidos enviada por correo'
      : 'Pedido $pedidos enviado por correo';
  String? motivo;
  try {
    await dataSource.enviarDocumentoCorreo(
        pedidos: pedidos, idExpo: idExpo, cotizacion: cotizacion);
    _aviso(messenger, enviado, Colors.green);
    return;
  } on CorreoClienteException catch (e) {
    motivo = e.message;
  } catch (e) {
    _avisoError(messenger, '$documento $pedidos', e, medio: 'correo');
    return;
  }

  if (!dialogContext.mounted) return;
  final correo =
      await _capturarCorreo(dialogContext, '$documento $pedidos', motivo);
  if (correo == null) return;

  try {
    await dataSource.enviarDocumentoCorreo(
      pedidos: pedidos,
      idExpo: idExpo,
      correo: correo,
      guardar: true,
      cotizacion: cotizacion,
    );
    _aviso(messenger, enviado, Colors.green);
  } catch (e) {
    _avisoError(messenger, '$documento $pedidos', e, medio: 'correo');
  }
}

Future<String?> _capturarCorreo(
    BuildContext context, String documento, String motivo) {
  final form = FormGroup({
    'correo': FormControl<String>(
        validators: [Validators.required, Validators.email]),
  });

  void aceptar(BuildContext dialog) {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }
    Navigator.of(dialog).pop((form.control('correo').value as String).trim());
  }

  final delDocumento = documento.startsWith('el ')
      ? 'del ${documento.substring(3)}'
      : 'de $documento';

  return showDialog<String>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Correo del cliente'),
      content: ReactiveForm(
        formGroup: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              motivo.contains('no tiene')
                  ? 'El cliente $delDocumento no tiene correo. '
                      'Captúralo para enviárselo; se guardará en el cliente.'
                  : 'El correo del cliente $delDocumento no es válido. '
                      'Captúralo de nuevo; se guardará en el cliente.',
            ),
            const SizedBox(height: 16),
            CustomReactiveTextField(
              formControlName: 'correo',
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validationMessages: {
                ValidationMessage.required: (error) => 'Captura el correo',
                ValidationMessage.email: (error) => 'Ingrese un correo correcto',
              },
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

typedef MediosEnvio = ({bool whatsapp, bool correo});

/// "¿Cómo se lo enviamos?" al terminar un pedido o cotización: WhatsApp y/o
/// correo (los dos marcados de entrada). null si se elige no enviar.
Future<MediosEnvio?> elegirMediosEnvio(BuildContext context, String titulo) {
  // Fuera del builder: el builder del diálogo se puede volver a llamar
  var whatsapp = true;
  var correo = true;
  return showDialog<MediosEnvio>(
    context: context,
    barrierDismissible: false,
    builder: (dialog) {
      return StatefulBuilder(
        builder: (dialog, setState) => AlertDialog(
          title: Text(titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('¿Cómo se lo enviamos al cliente?'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: whatsapp,
                onChanged: (v) => setState(() => whatsapp = v ?? false),
                secondary: const FaIcon(FontAwesomeIcons.whatsapp,
                    color: Color(0xFF25D366)),
                title: const Text('WhatsApp'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: correo,
                onChanged: (v) => setState(() => correo = v ?? false),
                secondary: const Icon(Icons.email_outlined),
                title: const Text('Correo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(),
              child: const Text('No enviar'),
            ),
            TextButton(
              onPressed: whatsapp || correo
                  ? () => Navigator.of(dialog)
                      .pop((whatsapp: whatsapp, correo: correo))
                  : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
      );
    },
  );
}

/// Manda por los medios elegidos, uno tras otro (cada uno con su aviso).
Future<void> enviarPorMedios({
  required BuildContext dialogContext,
  required ScaffoldMessengerState messenger,
  required String pedidos,
  required MediosEnvio medios,
  int? idExpo,
  bool cotizacion = false,
}) async {
  if (medios.whatsapp) {
    await enviarPedidoWhatsApp(
        dialogContext: dialogContext,
        messenger: messenger,
        pedidos: pedidos,
        idExpo: idExpo,
        cotizacion: cotizacion);
  }
  if (medios.correo && dialogContext.mounted) {
    await enviarPedidoCorreo(
        dialogContext: dialogContext,
        messenger: messenger,
        pedidos: pedidos,
        idExpo: idExpo,
        cotizacion: cotizacion);
  }
}
