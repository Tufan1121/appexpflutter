import 'package:appexpflutter_update/config/upper_case_text_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_filled_button.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';

// ignore: must_be_immutable
class ClienteFormEdit extends StatefulHookWidget {
  ClienteFormEdit({required this.cliente, super.key, required this.factura});
  final ClienteEntity cliente;
  ValueNotifier<bool> factura;

  @override
  State<ClienteFormEdit> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteFormEdit> {
  late String nombre;
  late String apellido;
  late String telefono;
  late String correo;

  late String rfc;

  @override
  Widget build(BuildContext context) {
    final form = FormGroup({
      'nombre': FormControl<String>(
          validators: [Validators.required], value: widget.cliente.nombre),
      'apellido': FormControl<String>(
          validators: [Validators.required], value: widget.cliente.apellido),
      'telefono': FormControl<String>(
          validators: [Validators.required], value: widget.cliente.telefono),
      'rfc': FormControl<String>(value: widget.cliente.rfc),
      'email': FormControl<String>(validators: [
        Validators.required,
        Validators.email,
      ], value: widget.cliente.correo),
    });
    widget.factura = useState(widget.cliente.factura == 1 ? true : false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
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
              onSubmitted: (p0) => _submitForm(form, context),
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
                ValidationMessage.email: (error) => 'Ingrese un correo correcto'
              },
            ),
            SwitchListTile(
              activeColor: Colores.secondaryColor,
              title: Text(widget.factura.value
                  ? 'Requiere Factura: Sí'
                  : 'Requiere Factura: No'),
              value: widget.factura.value,
              onChanged: (bool value) {
                widget.factura.value = value;
              },
            ),
            if (widget.factura.value)
              CustomReactiveTextField(
                formControlName: 'rfc',
                label: 'RFC',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z0-9]+$'),
                  ),
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomFilledButton(
                    text: 'Aceptar',
                    buttonColor: Colores.secondaryColor,
                    onPressed: () => _submitForm(form, context))),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  void _submitForm(FormGroup form, BuildContext context) {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }
    nombre = form.control('nombre').value!;
    apellido = form.control('apellido').value!;
    telefono = form.control('telefono').value!;
    correo = form.control('email').value!;
    rfc = form.control('rfc').value!;
    final data = {
      'id_cliente': widget.cliente.idCliente,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': correo,
      'factura': widget.factura.value == false ? 0 : 1,
      'rfc': widget.factura.value == false ? '' : rfc
    };

    context.read<ClienteBloc>().add(UpdateClientesEvent(data: data));
    Navigator.of(context).pop();
    FocusScope.of(context).unfocus();
  }
}
