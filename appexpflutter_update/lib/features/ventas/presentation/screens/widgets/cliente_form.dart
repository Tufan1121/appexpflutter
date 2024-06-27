import 'package:appexpflutter_update/config/upper_case_text_formatter.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            BlocConsumer<ClienteBloc, ClienteState>(
              listener: (context, state) {
                if (state is ClienteSave) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente creado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  form.control('apellido').reset();
                  form.control('telefono').reset();
                  form.control('email').reset();
                  nombre = form.control('nombre').value!;
                  factura.value = false;
                  PedidoRoute(idCliente: state.idCliente, nombreCliente: nombre).push(context);
                  form.control('nombre').reset();
                  
                } else if (state is ClienteError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: CustomFilledButton(
                        text: 'Guardar',
                        buttonColor: Colores.secondaryColor,
                        onPressed: _submitForm));
              },
            ),
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

    final data = {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': correo,
      'factura': factura.value == false ? 0 : 1
    };

    context.read<ClienteBloc>().add(CreateClientesEvent(data: data));
  }
}
