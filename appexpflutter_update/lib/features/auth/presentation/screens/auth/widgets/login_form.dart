import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colores.gradientStart,
            Colores.gradientMiddle,
            Colores.gradientEnd,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colores.gradientEnd.withOpacity(0.2),
                    blurRadius: 60,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: ReactiveForm(
                  formGroup: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colores.gradientStart,
                              Colores.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colores.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        '¡Bienvenido!',
                        style: textStyles.headlineLarge?.copyWith(
                          color: Colores.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: textStyles.bodyLarge?.copyWith(
                          color: Colores.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Email field
                      CustomReactiveTextField(
                        formControlName: 'email',
                        label: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                        validationMessages: {
                          ValidationMessage.required: (error) =>
                              'El correo es requerido',
                          ValidationMessage.email: (error) =>
                              'Ingresa un correo válido'
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Password field
                      CustomReactiveTextField(
                        formControlName: 'password',
                        label: 'Contraseña',
                        obscureText: showPassword.value,
                        onSubmitted: (p0) => _submitForm(),
                        validationMessages: {
                          ValidationMessage.required: (error) =>
                              'La contraseña es requerida',
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword.value
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Colores.textSecondary,
                            size: 22,
                          ),
                          onPressed: () => showPassword.value = !showPassword.value,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Login button with state
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 3),
                                backgroundColor: Colores.errorColor,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
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
                                        style: const TextStyle(
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
                              // Demo button - commented out for now, will be used later
                              // const SizedBox(height: 16),
                              // ModernButton(
                              //   text: 'Modo Demo',
                              //   isGradient: false,
                              //   isOutlined: true,
                              //   width: double.infinity,
                              //   icon: Icons.explore_rounded,
                              //   onPressed: isLoading
                              //       ? null
                              //       : () {
                              //           // Use the specific demo token provided
                              //           const demoToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJIZWxtdXQgSGVpc2UiLCJkaWdzaWciOiIyMDgiLCJyZWdnIjoxMDAzLCJtb3ZpbCI6IiIsImtpbmQiOjEsImRlc2NyaXBjaW8iOiJFWFBPUyBHREwiLCJ0b2tlbiI6IiIsImNlbXAiOiJUVUZBTiIsImV4cCI6MTc2OTcyNjU5MX0.enEKLT4U13NT7UFwDX2Rga6oEQWTuO9apFQ5far7tug";
                              //           context.read<AuthBloc>().add(const DemoLoginEvent(demoToken));
                              //           // Navigation is handled by the BlocListener listening for AuthAuthenticated
                              //         },
                              // ),
                              const SizedBox(height: 8),
                              Text(
                                'v1.1.10',
                                style: textStyles.bodySmall?.copyWith(
                                  color: Colores.textSecondary.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Footer text
                      Text(
                        '¿Olvidaste tu contraseña?',
                        style: textStyles.bodyMedium?.copyWith(
                          color: Colores.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // print('DEBUG: _submitForm called'); // DEBUG
    if (form.invalid) {
      form.markAllAsTouched();
      // print('DEBUG: Form is invalid'); // DEBUG
      return;
    }
    email = form.control('email').value!;
    password = form.control('password').value!;
    // print('DEBUG: Dispatching LoginEvent with email: $email'); // DEBUG
    // Realiza las acciones necesarias, como iniciar sesión
    context.read<AuthBloc>().add(LoginEvent(email, password));
  }
}
