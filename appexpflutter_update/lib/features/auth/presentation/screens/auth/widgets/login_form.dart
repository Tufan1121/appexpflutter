import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appexpflutter_update/features/shared/widgets/modern_button.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';

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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Iniciar sesión',
                style: textStyles.headlineMedium?.copyWith(
                  color: Colores.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tus credenciales',
                style: textStyles.bodyMedium?.copyWith(
                  color: Colores.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              CustomReactiveTextField(
                formControlName: 'email',
                label: 'Correo',
                keyboardType: TextInputType.emailAddress,
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'Este campo es requerido',
                  ValidationMessage.email: (error) =>
                      'Ingrese un correo correcto'
                },
              ),
              const SizedBox(height: 30),
              CustomReactiveTextField(
                formControlName: 'password',
                label: 'Contraseña',
                obscureText: showPassword.value,
                onSubmitted: (p0) => _submitForm(),
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'Este campo es requerido',
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    color: showPassword.value
                        ? Colors.grey
                        : Colores.secondaryColor,
                    size: 25,
                  ),
                  onPressed: () => showPassword.value = !showPassword.value,
                ),
              ),
              const SizedBox(height: 30),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colores.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, 
                                color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.message,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is AuthAuthenticated) {
                    // Navegar a la pantalla de inicio
                    HomeRoute().go(context);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  
                  return Column(
                    children: [
                      ModernButton(
                        text: 'Iniciar sesión',
                        isGradient: true,
                        isLoading: isLoading,
                        width: double.infinity,
                        onPressed: isLoading ? null : _submitForm,
                      ),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'MODO DEMO',
                        isGradient: false,
                        isOutlined: true,
                        width: double.infinity,
                        icon: Icons.explore_rounded,
                        onPressed: isLoading
                            ? null
                            : () {
                                HomeRoute().go(context);
                              },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }
    email = form.control('email').value!;
    password = form.control('password').value!;
    // Realiza las acciones necesarias, como iniciar sesión
    context.read<AuthBloc>().add(LoginEvent(email, password));
  }
}
