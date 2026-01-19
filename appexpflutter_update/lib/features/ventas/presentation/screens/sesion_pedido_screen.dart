import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/screen_utils.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/inventario/inventario_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
// import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/getpdf.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/session_pedido/sesion_pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../shared/widgets/layout_screens.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/payment_info/payment_info_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/payment_info/payment_info_state.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/cuenta_model.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/terminal_model.dart';

class SesionPedidoScreen extends StatefulHookWidget {
  const SesionPedidoScreen({
    super.key,
    required this.idCliente,
    required this.estadoPedido,
  });
  final int idCliente;
  final int estadoPedido;

  @override
  State<SesionPedidoScreen> createState() => _SesionPedidoScreenState();
}

class _SesionPedidoScreenState extends State<SesionPedidoScreen> {
  final form = FormGroup({
    'metodoDePago1': FormControl<String>(validators: [
      Validators.required,
    ]),
    'anticipoPago1': FormControl<double>(disabled: true, validators: [
      Validators.required,
    ]),
    'metodoDePago2': FormControl<String>(),
    'anticipoPago2': FormControl<double>(disabled: true),
    'metodoDePago3': FormControl<String>(),
    'anticipoPago3': FormControl<double>(disabled: true),
    'observaciones': FormControl<String>(
      validators: [
        Validators.required,
      ],
    ),
    'entregado': FormControl<bool>(value: false),
    'pendienteFinDeExpo': FormControl<bool>(value: true),
    'cuenta1': FormControl<String>(),
    'terminal1': FormControl<String>(),
    'cuenta2': FormControl<String>(),
    'terminal2': FormControl<String>(),
    'cuenta3': FormControl<String>(),
    'terminal3': FormControl<String>(),
  });

  final List<String> metodosDePago = [
    '01 Efectivo',
    '02 Cheque Nominativo',
    '03 Transferencia Electrónica',
    '04 Tarjeta de Crédito',
    '28 Tarjeta de débito',
    '82 Tarjeta de debito'
  ];

  int getMetodoDePagoId(String metodo) {
    return metodosDePago.indexOf(metodo) + 1;
  }

  final totalAPagar = UtilsVenta.total;

  // Future<void> _openPDF(String pdfUrl) async {
  //   try {
  //     // Lanzar la URL en un visor de PDF externo
  //     await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication);
  //   } catch (e) {
  //     // Manejar errores si la URL no se puede abrir
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('No se pudo abrir el PDF'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isEntregado = useState(false);
    final loading = useState(false);

    final isPendienteFinDeExpo = useState(true);
    final size = MediaQuery.of(context).size;
    final debePorPagar = useState(totalAPagar);
    final scrollController = useScrollController();

    void toggleCheckbox(String controlName) {
      if (controlName == 'entregado') {
        isEntregado.value = true;
        isPendienteFinDeExpo.value = false;
        form.control('entregado').value = isEntregado.value;
        form.control('pendienteFinDeExpo').value = isPendienteFinDeExpo.value;
      } else if (controlName == 'pendienteFinDeExpo') {
        isEntregado.value = false;
        isPendienteFinDeExpo.value = true;
        form.control('entregado').value = isEntregado.value;
        form.control('pendienteFinDeExpo').value = isPendienteFinDeExpo.value;
      }
    }

    void updateDebePorPagar() {
      final anticipoPago1 = form.control('anticipoPago1').value ?? 0.0;
      final anticipoPago2 = form.control('anticipoPago2').value ?? 0.0;
      final anticipoPago3 = form.control('anticipoPago3').value ?? 0.0;
      final totalAnticipo = anticipoPago1 + anticipoPago2 + anticipoPago3;
      debePorPagar.value = totalAPagar - totalAnticipo;
    }

    useEffect(() {
      form
          .control('anticipoPago1')
          .valueChanges
          .listen((_) => updateDebePorPagar());
      form
          .control('anticipoPago2')
          .valueChanges
          .listen((_) => updateDebePorPagar());
      form
          .control('anticipoPago3')
          .valueChanges
          .listen((_) => updateDebePorPagar());

      return null;
    }, []);
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'SESION PEDIDO',
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 700, // 80 los dos sizebox
              width: double.infinity,

              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ReactiveForm(
                    formGroup: form,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SizedBox(
                          height: size.height * 0.95,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total a pagar'),
                                      Text(
                                        Utils.formatPrice(UtilsVenta.total),
                                        style: const TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Debe por pagar'),
                                      Text(
                                        Utils.formatPrice(debePorPagar.value),
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              buildDropdownAndTextField(
                                  context: context,
                                  hintText: 'Selecciona Método de Pago 1',
                                  controlNameDropdown: 'metodoDePago1',
                                  controlNameTextField: 'anticipoPago1',
                                  controlNameCuenta: 'cuenta1',
                                  controlNameTerminal: 'terminal1',
                                  validationMessages: {
                                    ValidationMessage.required: (error) =>
                                        'Este campo es requerido'
                                  }),
                              const SizedBox(height: 10.0),
                              buildDropdownAndTextField(
                                context: context,
                                hintText: 'Selecciona Método de Pago 2',
                                controlNameDropdown: 'metodoDePago2',
                                controlNameTextField: 'anticipoPago2',
                                controlNameCuenta: 'cuenta2',
                                controlNameTerminal: 'terminal2',
                              ),
                              const SizedBox(height: 10.0),
                              buildDropdownAndTextField(
                                context: context,
                                hintText: 'Selecciona Método de Pago 3',
                                controlNameDropdown: 'metodoDePago3',
                                controlNameTextField: 'anticipoPago3',
                                controlNameCuenta: 'cuenta3',
                                controlNameTerminal: 'terminal3',
                              ),
                              const SizedBox(height: 10.0),
                              ReactiveTextField(
                                formControlName: 'observaciones',
                                decoration: const InputDecoration(
                                    labelText: 'Observaciones'),
                                maxLines: 3, // Permitir múltiples líneas
                                keyboardType: TextInputType.multiline,
                                onTapOutside: (event) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                validationMessages: {
                                  ValidationMessage.required: (error) =>
                                      'Este campo es requerido',
                                },
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                children: [
                                  Checkbox(
                                    value: isEntregado.value,
                                    activeColor: Colores.secondaryColor,
                                    onChanged: (value) =>
                                        toggleCheckbox('entregado'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  const Text('Entregado'),
                                  const SizedBox(width: 20.0),
                                  Checkbox(
                                    value: isPendienteFinDeExpo.value,
                                    activeColor: Colores.secondaryColor,
                                    onChanged: (value) =>
                                        toggleCheckbox('pendienteFinDeExpo'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  const Text('Pendiente fin de expo'),
                                ],
                              ),
                              const SizedBox(height: 32.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  BlocConsumer<SesionPedidoBloc,
                                      SesionPedidoState>(
                                    listener: (context, state) {
                                      if (state is PedidoSesionLoading) {
                                        loading.value = true;
                                      }
                                      if (state is PedidoDetalleSesionLoaded) {
                                        loading.value = false;
                                        debePorPagar.value = 0.0;

                                        ScaffoldMessenger.of(context)
                                            .removeCurrentSnackBar();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(state.message),
                                          backgroundColor: Colors.green,
                                        ));

                                        form.control('metodoDePago1').reset();
                                        form.control('metodoDePago2').reset();
                                        form.control('metodoDePago3').reset();
                                        form.control('observaciones').reset();
                                        form.control('anticipoPago1').reset();
                                        form.control('anticipoPago2').reset();
                                        form.control('anticipoPago3').reset();
                                        form.control('entregado').reset();

                                        // Aquí  la URL donde está ubicado el PDF
                                        // String pdfUrl =
                                        //     'https://tapetestufan.mx/expo/${state.pedido.idExpo}/pdf/${state.pedido.pedidos}.pdf'; // Sustituye con tu URL real
                                        // _openPDF(pdfUrl);

                                        // _showDownloadModal(context, pdfUrl,
                                        //     state.pedido.pedidos);

                                        //  form.reset();
                                        context
                                            .read<ClienteBloc>()
                                            .add(ClearClienteStateEvent());
                                        context
                                            .read<ProductosBloc>()
                                            .add(ClearProductoStateEvent());
                                        context
                                            .read<SesionPedidoBloc>()
                                            .add(ClearPedidoSesionEvent());
                                        context.read<InventarioBloc>().add(
                                            ClearInventarioProductoEvent());
                                        HomeRoute().go(context);
                                      } else if (state is PedidoSesionError) {
                                        loading.value = false;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(state.message),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    builder: (context, state) {
                                      return ElevatedButton.icon(
                                        onPressed:
                                            loading.value ? null : _submitForm,
                                        icon: const Icon(
                                          Icons.save,
                                          color:
                                              Colores.scaffoldBackgroundColor,
                                        ),
                                        label: Text(
                                          loading.value
                                              ? 'ESPERE..'
                                              : 'GUARDAR',
                                          style: TextStyle(
                                              color: loading.value
                                                  ? Colores.secondaryColor
                                                  : Colores
                                                      .scaffoldBackgroundColor),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colores.secondaryColor),
                                      );
                                    },
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _dialogCancel,
                                    icon: const Icon(Icons.close,
                                        color: Colores.secondaryColor),
                                    label: const Text(
                                      'CANCELAR',
                                      style: TextStyle(
                                          color: Colores.secondaryColor),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildDropdownAndTextField({
    required BuildContext context,
    required String hintText,
    required String controlNameDropdown,
    required String controlNameTextField,
    String? controlNameCuenta,
    String? controlNameTerminal,
    Map<String, String Function(Object)>? validationMessages,
  }) {
    final enable = useState(false);
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                  width: ScreenUtils.percentWidth(context, 80),
                  height: ScreenUtils.percentHeight(context, 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 5))
                      ])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ReactiveDropdownField<String>(
                  validationMessages: validationMessages,
                  formControlName: controlNameDropdown,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      hintText: hintText,
                      border: InputBorder.none),
                  items: metodosDePago.map((String metodo) {
                    return DropdownMenuItem<String>(
                      value: metodo,
                      child: Text(metodo),
                    );
                  }).toList(),
                  onChanged: (control) {
                    form.control(controlNameTextField).markAsEnabled();
                    enable.value = form.control(controlNameTextField).disabled;

                    if (controlNameCuenta != null) form.control(controlNameCuenta).reset();
                    if (controlNameTerminal != null) form.control(controlNameTerminal).reset();
                  },
                ),
              ),
            ],
          ),
          
          // Conditional Dropdowns
           ReactiveValueListenableBuilder<String?>(
            formControlName: controlNameDropdown,
            builder: (context, control, child) {
              final String? method = control.value;
              if (method == null) return const SizedBox.shrink();

              // Logic for Accounts: 01 Efectivo, 03 Transferencia
              if ((method.contains('01') || method.contains('03')) && controlNameCuenta != null) {
                 return BlocBuilder<PaymentInfoBloc, PaymentInfoState>(
                   builder: (context, state) {
                     if (state is PaymentInfoLoaded) {
                       return Padding(
                         padding: const EdgeInsets.only(top: 10.0),
                         child: Stack(
                           alignment: AlignmentDirectional.center,
                           children: [
                             Container(
                                 width: ScreenUtils.percentWidth(context, 80),
                                 height: ScreenUtils.percentHeight(context, 5),
                                 decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular(50),
                                     border: Border.all(color: Colors.grey.shade300),
                                 )),
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
                               child: ReactiveDropdownField<String>( // Changed to String
                                 formControlName: controlNameCuenta,
                                 decoration: const InputDecoration(
                                     hintText: 'Selecciona Cuenta',
                                     border: InputBorder.none),
                                 items: state.cuentas.map((e) => DropdownMenuItem(
                                   value: e.id, // e.id is String
                                   child: Text(e.nombre),
                                 )).toList(),
                               ),
                             ),
                           ],
                         ),
                       );
                     }
                     return const SizedBox.shrink();
                   },
                 );
              }
              
              // Logic for Terminals: 04 Tarjeta de crédito, 28 Tarjeta de débito, 82 Tarjeta de debito
              if ((method.contains('04') || method.contains('28') || method.contains('82')) && controlNameTerminal != null) {
                return BlocBuilder<PaymentInfoBloc, PaymentInfoState>(
                   builder: (context, state) {
                     if (state is PaymentInfoLoaded) {
                       return Padding(
                         padding: const EdgeInsets.only(top: 10.0),
                         child: Stack(
                           alignment: AlignmentDirectional.center,
                           children: [
                             Container(
                                 width: ScreenUtils.percentWidth(context, 80),
                                 height: ScreenUtils.percentHeight(context, 5),
                                 decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular(50),
                                     border: Border.all(color: Colors.grey.shade300),
                                 )),
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
                               child: ReactiveDropdownField<String>( // Changed to String
                                 formControlName: controlNameTerminal,
                                 decoration: const InputDecoration(
                                     hintText: 'Selecciona Terminal',
                                     border: InputBorder.none),
                                 items: state.terminales.map((e) => DropdownMenuItem(
                                   value: e.id, // e.id is String
                                   child: Text(e.nombre),
                                 )).toList(),
                               ),
                             ),
                           ],
                         ),
                       );
                     }
                     return const SizedBox.shrink();
                   },
                 );
              }

              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 4.0),
          Stack(
            children: [
              SizedBox(
                  width: ScreenUtils.percentWidth(context, 80),
                  height: ScreenUtils.percentHeight(context, 4.0)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ReactiveTextField(
                  formControlName: controlNameTextField,
                  validationMessages: validationMessages,
                  decoration: const InputDecoration(
                      hintText: 'Anticipo o Pago',
                      prefixIcon: Padding(
                        padding:
                            EdgeInsets.only(top: 15.0, left: 15.0, right: 5.0),
                        child:
                            Text('\$', style: TextStyle(color: Colors.black)),
                      ),
                      suffixText: 'MXN',
                      contentPadding:
                          EdgeInsets.only(top: 15.0, left: 15.0, right: 5.0),
                      alignLabelWithHint: true),
                  keyboardType: TextInputType.number,
                  readOnly: enable.value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (form.valid) {
      // Maneja el envío del formulario
      final metodo1 = form.control('metodoDePago1').value != null
          ? getMetodoDePagoId(form.control('metodoDePago1').value)
          : 0;
      final metodo2 = form.control('metodoDePago2').value != null
          ? getMetodoDePagoId(form.control('metodoDePago2').value)
          : 0;
      final metodo3 = form.control('metodoDePago3').value != null
          ? getMetodoDePagoId(form.control('metodoDePago3').value)
          : 0;
      final String observaciones = form.control('observaciones').value;

      final double anticipoPago = form.control('anticipoPago1').value ?? 0.0;
      final double anticipoPago2 = form.control('anticipoPago2').value ?? 0.0;
      final double anticipoPago3 = form.control('anticipoPago3').value ?? 0.0;
      final entregado = form.control('entregado').value ? 1 : 0;

      // Obtener información de cuentas y terminales desde el estado del Bloc
      final paymentInfoState = context.read<PaymentInfoBloc>().state;
      
      // Helper para obtener cuenta por ID
      CuentaModel? getCuentaById(String? id) {
        if (id == null || paymentInfoState is! PaymentInfoLoaded) return null;
        try {
          return paymentInfoState.cuentas.firstWhere((c) => c.id == id);
        } catch (_) {
          return null;
        }
      }
      
      // Helper para obtener terminal por ID
      TerminalModel? getTerminalById(String? id) {
        if (id == null || paymentInfoState is! PaymentInfoLoaded) return null;
        try {
          return paymentInfoState.terminales.firstWhere((t) => t.id == id);
        } catch (_) {
          return null;
        }
      }

      // Obtener datos de pago 1
      final cuenta1 = getCuentaById(form.control('cuenta1').value);
      final terminal1 = getTerminalById(form.control('terminal1').value);
      
      // Obtener datos de pago 2
      final cuenta2 = getCuentaById(form.control('cuenta2').value);
      final terminal2 = getTerminalById(form.control('terminal2').value);
      
      // Obtener datos de pago 3
      final cuenta3 = getCuentaById(form.control('cuenta3').value);
      final terminal3 = getTerminalById(form.control('terminal3').value);

      final data = {
        'id_cliente': widget.idCliente,
        'id_metodopago': metodo1,
        // banco/cuenta SIEMPRE se llenan (de cuenta o terminal, el que esté disponible)
        // terminal solo se llena cuando hay terminal
        'banco1': cuenta1?.banco ?? terminal1?.banco ?? '',
        'cuenta1': cuenta1?.cuenta ?? terminal1?.cuenta ?? '',
        'dig1': '',  // No existe en los endpoints, siempre vacío
        'terminal1': terminal1?.id ?? '',
        'observaciones': observaciones,
        'estatus': widget.estadoPedido,
        'anticipo': anticipoPago,
        'anticipo2': anticipoPago2,
        'anticipo3': anticipoPago3,
        'total_pagar': totalAPagar,
        'entregado': entregado,
        'id_metodopago2': metodo2,
        'banco2': cuenta2?.banco ?? terminal2?.banco ?? '',
        'cuenta2': cuenta2?.cuenta ?? terminal2?.cuenta ?? '',
        'dig2': '',  // No existe en los endpoints, siempre vacío
        'terminal2': terminal2?.id ?? '',
        'id_metodopago3': metodo3,
        'banco3': cuenta3?.banco ?? terminal3?.banco ?? '',
        'cuenta3': cuenta3?.cuenta ?? terminal3?.cuenta ?? '',
        'dig3': '',  // No existe en los endpoints, siempre vacío
        'terminal3': terminal3?.id ?? '',
      };

      // DEBUG: Mostrar JSON completo que se enviará
      print('═══════════════════════════════════════════════════════════════');
      print('🚀 ENVIANDO PEDIDO DE SESIÓN AL BACKEND');
      print('═══════════════════════════════════════════════════════════════');
      print('📋 DATOS DEL CLIENTE:');
      print('  ID Cliente: ${data['id_cliente']}');
      print('');
      print('💰 MÉTODO DE PAGO 1:');
      print('  ID Método: ${data['id_metodopago']} (${metodo1 > 0 ? metodosDePago[metodo1 - 1] : 'N/A'})');
      print('  Banco: "${data['banco1']}"');
      print('  Cuenta: "${data['cuenta1']}"');
      print('  Dig: "${data['dig1']}"');
      print('  Terminal: "${data['terminal1']}"');
      print('  Anticipo: \$${data['anticipo']}');
      print('');
      if (metodo2 > 0) {
        print('💳 MÉTODO DE PAGO 2:');
        print('  ID Método: ${data['id_metodopago2']} (${metodosDePago[metodo2 - 1]})');
        print('  Banco: "${data['banco2']}"');
        print('  Cuenta: "${data['cuenta2']}"');
        print('  Dig: "${data['dig2']}"');
        print('  Terminal: "${data['terminal2']}"');
        print('  Anticipo: \$${data['anticipo2']}');
        print('');
      }
      if (metodo3 > 0) {
        print('💵 MÉTODO DE PAGO 3:');
        print('  ID Método: ${data['id_metodopago3']} (${metodosDePago[metodo3 - 1]})');
        print('  Banco: "${data['banco3']}"');
        print('  Cuenta: "${data['cuenta3']}"');
        print('  Dig: "${data['dig3']}"');
        print('  Terminal: "${data['terminal3']}"');
        print('  Anticipo: \$${data['anticipo3']}');
        print('');
      }
      print('📊 TOTALES:');
      print('  Total a Pagar: \$${data['total_pagar']}');
      print('  Entregado: ${data['entregado'] == 1 ? 'Sí' : 'No'}');
      print('  Estatus: ${data['estatus']}');
      print('');
      print('📝 JSON COMPLETO:');
      print(data);
      print('═══════════════════════════════════════════════════════════════');

      context.read<SesionPedidoBloc>().add(PedidoAddSesionEvent(
          data: data, products: UtilsVenta.listProductsOrder));
    } else {
      form.markAllAsTouched();
    }
  }

  Future<void> _dialogCancel() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                'Atención',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: const SizedBox(
            height: 50,
            child: Column(
              children: [
                Text(
                  '¿Deseas cancelar el pedido?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Los cambios no se guardarán.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colores.secondaryColor),
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colores.secondaryColor,
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colores.scaffoldBackgroundColor),
              ),
              onPressed: () {
                // FocusScope.of(context).unfocus();
                // context.read<ClienteBloc>().add(ClearClienteStateEvent());
                // context.read<ProductosBloc>().add(ClearProductoStateEvent());
                // context.read<SesionPedidoBloc>().add(ClearPedidoStateEvent());
                // context
                //     .read<InventarioBloc>()
                //     .add(ClearInventarioProductoEvent());
                // HomeRoute().go(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}