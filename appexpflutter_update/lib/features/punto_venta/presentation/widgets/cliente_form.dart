import 'package:appexpflutter_update/config/upper_case_text_formatter.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
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
  late String direccion;
  late String telefono;
  late String correo;
  late String rfc;
  late ValueNotifier<bool> factura;
  bool isEnabled = false;

  final form = FormGroup({
    'nombre': FormControl<String>(validators: [Validators.required]),
    'direccion': FormControl<String>(validators: [Validators.required]),
    'telefono': FormControl<String>(validators: [Validators.required]),
    'rfc': FormControl<String>(),
    'email': FormControl<String>(validators: [
      Validators.required,
      // Validators.email,
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
            // Jalar un cliente ya registrado y pre-llenar los campos, en vez
            // de capturarlo de nuevo.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _buscarClienteExistente,
                icon: const Icon(Icons.person_search,
                    color: Colores.secondaryColor),
                label: const Text(
                  'BUSCAR CLIENTE EXISTENTE',
                  style: TextStyle(color: Colores.secondaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colores.secondaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            CustomReactiveTextField(
              formControlName: 'nombre',
              label: 'Nombre',
              inputFormatters: [
                // FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                UpperCaseTextFormatter(),
              ],
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
              },
            ),
            const SizedBox(height: 20),
            CustomReactiveTextField(
              formControlName: 'direccion',
              label: 'Dirección',
              inputFormatters: [
                // FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
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
              onSubmitted: (p0) => _submitForm(form),
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Este campo es requerido',
                // ValidationMessage.email: (error) => 'Ingrese un correo correcto'
              },
            ),
            // SwitchListTile(
            //   activeColor: Colores.secondaryColor,
            //   title: Text(factura.value
            //       ? 'Requiere Factura: Sí'
            //       : 'Requiere Factura: No'),
            //   value: factura.value,
            //   onChanged: (bool value) {
            //     factura.value = value;
            //   },
            // ),
            // if (factura.value)
            //   CustomReactiveTextField(
            //     formControlName: 'rfc',
            //     label: 'RFC',
            //     inputFormatters: [
            //       FilteringTextInputFormatter.allow(
            //         RegExp(r'^[a-zA-Z0-9]+$'),
            //       ),
            //       UpperCaseTextFormatter(),
            //       LengthLimitingTextInputFormatter(13),
            //     ],
            //   ),
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

                  nombre = form.control('nombre').value!;
                  telefono = form.control('telefono').value!;
                  factura.value = false;
                  PedidoRoute(
                          idCliente: state.idCliente,
                          nombreCliente: nombre,
                          telefonoCliente: telefono)
                      .push(context);
                  form.control('nombre').reset();
                  form.control('direccion').reset();
                  form.control('telefono').reset();
                  form.control('email').reset();
                  // form.control('rfc').reset();
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
                        onPressed: () => _submitForm(form)));
              },
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  /// Abre la búsqueda de clientes registrados; al elegir uno pre-llena los
  /// campos del formulario y conserva su id para el ticket.
  Future<void> _buscarClienteExistente() async {
    FocusScope.of(context).unfocus();
    final cliente = await showModalBottomSheet<ClienteEntity>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.7,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 4),
                  child: Text(
                    'BUSCAR CLIENTE EXISTENTE',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colores.secondaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: TextField(
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    // El bloc ya trae debounce de 500 ms, así que se puede
                    // buscar mientras teclea sin saturar el backend.
                    onChanged: (value) {
                      if (value.trim().length >= 2) {
                        sheetContext
                            .read<ClienteBloc>()
                            .add(GetClientesEvent(name: value.trim()));
                      }
                    },
                    onSubmitted: (value) => sheetContext
                        .read<ClienteBloc>()
                        .add(GetClientesEvent(name: value.trim())),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Nombre del cliente',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<ClienteBloc, ClienteState>(
                    builder: (context, state) {
                      if (state is ClienteLoading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (state is ClienteError) {
                        return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.red)),
                        );
                      }
                      if (state is ClienteLoaded) {
                        if (state.clientes.isEmpty) {
                          return const Center(
                              child: Text('Sin resultados'));
                        }
                        return ListView.separated(
                          itemCount: state.clientes.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final c = state.clientes[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.person,
                                  color: Colores.secondaryColor),
                              title: Text('${c.nombre} ${c.apellido}'.trim()),
                              subtitle: Text(
                                  'Tel: ${c.telefono}  ·  ${c.correo}'),
                              onTap: () =>
                                  Navigator.of(sheetContext).pop(c),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text(
                          'Escribe el nombre para buscar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    // Dejar la búsqueda limpia para la próxima vez.
    context.read<ClienteBloc>().add(ClearClienteStateEvent());
    if (cliente == null) return;

    // Solo pre-llenar los campos; el ticket no liga el id del cliente.
    form.control('nombre').value =
        '${cliente.nombre} ${cliente.apellido}'.trim().toUpperCase();
    form.control('direccion').value =
        (cliente.direccion ?? '').trim().toUpperCase();
    form.control('telefono').value = cliente.telefono.trim();
    form.control('email').value = cliente.correo.trim();
  }

  void _submitForm(FormGroup form) {
    FocusScope.of(context).unfocus();
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }
    nombre = form.control('nombre').value!;
    direccion = form.control('direccion').value!;
    telefono = form.control('telefono').value!;
    correo = form.control('email').value!;
    // rfc = form.control('rfc').value ?? '';

    final data = {
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'correo': correo,
      // 'factura': factura.value == false ? 0 : 1,
      // 'rfc': rfc
    };

    TicketsRoute($extra: data).push(context);
  }
}
