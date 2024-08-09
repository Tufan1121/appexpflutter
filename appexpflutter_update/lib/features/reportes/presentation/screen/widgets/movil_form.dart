import 'package:appexpflutter_update/features/reportes/presentation/bloc/reportes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_filled_button.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';

class MovilForm extends StatefulHookWidget {
  const MovilForm({super.key});

  @override
  State<MovilForm> createState() => _MovilForm();
}

class _MovilForm extends State<MovilForm> {
  late String movil;

  final form = FormGroup({
    'movil': FormControl<String>(validators: [Validators.required]),
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final showPassword = useState(true);
    final isLoading = useState(false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              'Ingresa tu Código Móvil',
              style: textStyles.titleLarge,
            ),
            const SizedBox(height: 90),
            CustomReactiveTextField(
              formControlName: 'movil',
              label: 'Código Móvil',
              obscureText: showPassword.value,
              keyboardType: TextInputType.number,
              onSubmitted: (p0) => _submitForm(),
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[0-9]*$'),
                ),
              ],
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color:
                      showPassword.value ? Colors.grey : Colores.secondaryColor,
                  size: 25,
                ),
                onPressed: () => showPassword.value = !showPassword.value,
              ),
            ),
            const SizedBox(height: 30),
            BlocConsumer<ReportesBloc, ReportesState>(
              listener: (context, state) {
                if (state is ReportesLoading) {
                  isLoading.value = true;
                }
                if (state is AuthMovil) {
                  if (state.isAuthMovil == false) {
                    isLoading.value = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red,
                        content: Text(
                          'Código incorrecto',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    isLoading.value = false;
                    context.read<ReportesBloc>().add(GetReportesPedidosEvent());
                    context.read<ReportesBloc>().add(GetReportesTicketsEvent());
                    ReportesScreenRoute().push(context);
                  }
                }
              },
              builder: (context, state) {
                return SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: CustomFilledButton(
                        text: isLoading.value
                            ? 'Cargando...'
                            : 'Visualizar Reportes',
                        buttonColor: Colores.secondaryColor,
                        onPressed: isLoading.value ? null : _submitForm));
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
    movil = form.control('movil').value!;
    context.read<ReportesBloc>().add(AuthMovilEvent(movil: movil));
  }
}
