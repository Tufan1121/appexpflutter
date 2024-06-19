import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_filled_button.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';

class ClienteForm extends StatefulHookWidget {
  const ClienteForm({super.key});

  @override
  State<ClienteForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<ClienteForm> {
  late String nombre;
  late String apellido;
  late String telefono;
  late String correo;
  late ValueNotifier<bool> factura;

  final form = FormGroup({
    'nombre': FormControl<String>(validators: [Validators.required]),
    'apellido': FormControl<String>(validators: [Validators.required]),
    'telefono': FormControl<String>(validators: [Validators.required]),
    'email': FormControl<String>(validators: [
      Validators.required,
      Validators.email,
    ]),
  });

  @override
  Widget build(BuildContext context) {
    factura = useState(false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            CustomReactiveTextField(
              formControlName: 'nombre',
              label: 'Nombre',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                UpperCaseTextFormatter(),
              ],
              keyboardType: TextInputType.emailAddress,
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
              },
            ),
            const SizedBox(height: 20),
            CustomReactiveTextField(
              formControlName: 'apellido',
              label: 'Apellido',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                UpperCaseTextFormatter(),
              ],
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
              },
            ),
            const SizedBox(height: 20),
            CustomReactiveTextField(
              formControlName: 'telefono',
              label: 'Telefono/WhatsApp',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[0-9]*$'),
                ),
                LengthLimitingTextInputFormatter(10),
              ],
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
              },
            ),
            const SizedBox(height: 20),
            CustomReactiveTextField(
              formControlName: 'email',
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (p0) => _submitForm(),
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
                ValidationMessage.email: (error) => 'Ingrese un correo correcto'
              },
            ),
            SwitchListTile(
              activeColor: Colores.secondaryColor,
              title: Text(factura.value
                  ? 'Requiere Factura: Sí'
                  : 'Requiere Factura: No'),
              value: factura.value,
              onChanged: (bool value) {
                factura.value = value;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomFilledButton(
                    text: 'Guardar',
                    buttonColor: Colores.secondaryColor,
                    onPressed: () => _submitForm())),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }
    nombre = form.control('nombre').value!;
    apellido = form.control('apellido').value!;
    telefono = form.control('telefono').value!;
    correo = form.control('email').value!;

    print('''
CLIENTE:
        nombre: $nombre
        apellido: $apellido
        telefono: $telefono
        correo: $correo
        factura: ${factura.value}
''');
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
