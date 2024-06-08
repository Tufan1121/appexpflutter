import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:appexpflutter_update/presentation/shared/widgets/custom_filled_button.dart';
import 'package:appexpflutter_update/presentation/shared/widgets/custom_text_form_field.dart';

class LoginForm extends StatefulHookWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late String email;
  late String password;

  final form = FormGroup({
    'email': FormControl<String>(validators: [
      Validators.required,
      Validators.email,
    ]),
    'password': FormControl<String>(validators: [Validators.required]),
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final showPassword = useState(true);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              'Iniciar sesión ',
              style: textStyles.titleLarge,
            ),
            const SizedBox(height: 90),
            CustomReactiveTextField(
              formControlName: 'email',
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
                ValidationMessage.email: (error) => 'Ingrese un correo correcto'
              },
            ),
            const SizedBox(height: 30),
            CustomReactiveTextField(
              formControlName: 'password',
              label: 'Contraseña',
              obscureText: showPassword.value,
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
              },
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: showPassword.value
                      ? Colors.grey
                      : const Color(0xffD90080),
                  size: 25,
                ),
                onPressed: () => showPassword.value = !showPassword.value,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomFilledButton(
                  text: 'Iniciar sesión',
                  buttonColor: const Color(0xffD90080),
                  onPressed: () {
                    if (form.invalid) {
                      form.markAllAsTouched();
                      return;
                    }
                    email = form.control('email').value!;
                    password = form.control('password').value!;
                  },
                )),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
