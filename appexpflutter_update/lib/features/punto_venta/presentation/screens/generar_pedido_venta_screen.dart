import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/miles_input_formatter.dart';
import 'package:appexpflutter_update/config/utils/limite_importe_formatter.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/cuenta_model.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/terminal_model.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/inventario_tienda/inventario_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/payment_info/payment_info_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/payment_info/payment_info_event.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/payment_info/payment_info_state.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/pedido/pedido_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../config/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GenerarPedidoVentaScreen extends StatefulHookWidget {
  const GenerarPedidoVentaScreen({
    super.key,
    required this.estadoPedido,
    this.idSesion,
    required this.dataCliente,
  });

  final int estadoPedido;
  final int? idSesion;
  final Map<String, dynamic> dataCliente;

  @override
  State<GenerarPedidoVentaScreen> createState() =>
      _GenerarPedidoVentaScreenState();
}

class _GenerarPedidoVentaScreenState extends State<GenerarPedidoVentaScreen> {
  final form = FormGroup({
    'metodoDePago1': FormControl<String>(validators: [Validators.required]),
    'anticipoPago1':
        FormControl<double>(disabled: true, validators: [Validators.required]),
    'metodoDePago2': FormControl<String>(),
    'anticipoPago2': FormControl<double>(disabled: true),
    'metodoDePago3': FormControl<String>(),
    'anticipoPago3': FormControl<double>(disabled: true),
    'observaciones': FormControl<String>(),
    'entregado': FormControl<bool>(value: false),
    'pendienteFinDeExpo': FormControl<bool>(value: true),
    // Cuenta (efectivo/transferencia) o terminal (tarjeta) de cada pago
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
    '28 Tarjeta de débito'
  ];

  int getMetodoDePagoId(String metodo) {
    return metodosDePago.indexOf(metodo) + 1;
  }

  /// Tolerancia para comparar importes (evita falsos positivos por redondeo).
  static const double _tolerancia = 0.01;

  double _anticipoDe(String controlName) {
    final valor = form.control(controlName).value;
    if (valor is num) return valor.toDouble();
    return 0.0;
  }

  /// Suma de los anticipos capturados, opcionalmente sin uno de los campos.
  double sumaAnticipos({String? excepto}) {
    double suma = 0.0;
    for (final control in const [
      'anticipoPago1',
      'anticipoPago2',
      'anticipoPago3'
    ]) {
      if (control == excepto) continue;
      suma += _anticipoDe(control);
    }
    return suma;
  }

  /// Máximo que se puede capturar en un campo de pago: lo que falta por pagar
  /// considerando lo ya capturado en los otros dos campos.
  double maximoCapturable(String controlName) {
    final restante =
        UtilsVenta.totalWithShipping - sumaAnticipos(excepto: controlName);
    return restante > 0 ? restante : 0.0;
  }

  /// Marca de tiempo del último aviso de límite, para no saturar de snackbars
  /// mientras el usuario sigue tecleando.
  DateTime? _ultimoAvisoLimite;

  void _avisarLimite(BuildContext context, double maximo) {
    final ahora = DateTime.now();
    if (_ultimoAvisoLimite != null &&
        ahora.difference(_ultimoAvisoLimite!) < const Duration(seconds: 2)) {
      return;
    }
    _ultimoAvisoLimite = ahora;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
              'El pago no puede exceder lo que falta por pagar: ${Utils.formatPrice(maximo)}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Evita que un doble toque en GUARDAR genere dos tickets: el estado
  /// de carga del bloc llega un microtask después del primer toque.
  bool _enviando = false;

  @override
  Widget build(BuildContext context) {
    // El total se lee en vivo en cada build
    final totalAPagar = UtilsVenta.totalWithShipping;
    final debePorPagar = useState(totalAPagar);
    final scrollController = useScrollController();
    final loading = useState(false);

    void updateDebePorPagar() {
      debePorPagar.value = UtilsVenta.totalWithShipping - sumaAnticipos();
    }

    // Sincronizar cuando el total cambie (p. ej. se regresa y se modifican precios)
    useEffect(() {
      updateDebePorPagar();
      return null;
    }, [totalAPagar]);

    useEffect(() {
      final subs = [
        for (final c in const ['anticipoPago1', 'anticipoPago2', 'anticipoPago3'])
          form.control(c).valueChanges.listen((_) => updateDebePorPagar()),
      ];
      // Cuentas y terminales de la tienda para los pagos
      context.read<PaymentInfoBloc>().add(LoadPaymentInfoEvent());
      return () {
        for (final s in subs) {
          s.cancel();
        }
      };
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(40.0),
                  child: CustomAppBar(
                    backgroundColor: Colors.transparent,
                    color: Colores.secondaryColor,
                    onPressed: () => Navigator.pop(context),
                    title: 'GENERAR TICKET',
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ReactiveForm(
                                  formGroup: form,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16.0),
                                      _buildTotales(debePorPagar),
                                      const SizedBox(height: 10.0),
                                      _buildDropdownAndTextField(
                                        context: context,
                                        hintText: 'Selecciona Método de Pago 1',
                                        controlNameDropdown: 'metodoDePago1',
                                        controlNameTextField: 'anticipoPago1',
                                        controlNameCuenta: 'cuenta1',
                                        controlNameTerminal: 'terminal1',
                                        validationMessages: {
                                          ValidationMessage.required: (error) =>
                                              'Este campo es requerido'
                                        },
                                      ),
                                      const SizedBox(height: 10.0),
                                      _buildDropdownAndTextField(
                                        context: context,
                                        hintText: 'Selecciona Método de Pago 2',
                                        controlNameDropdown: 'metodoDePago2',
                                        controlNameTextField: 'anticipoPago2',
                                        controlNameCuenta: 'cuenta2',
                                        controlNameTerminal: 'terminal2',
                                      ),
                                      const SizedBox(height: 10.0),
                                      _buildDropdownAndTextField(
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
                                        maxLines: 3,
                                        keyboardType: TextInputType.multiline,
                                        onTapOutside: (event) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        },
                                      ),
                                      const SizedBox(height: 20.0),
                                      _buildActionButtons(
                                          context, loading, debePorPagar),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotales(ValueNotifier<double> debePorPagar) {
    final cobroDeMas = debePorPagar.value < -_tolerancia;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(UtilsVenta.hasShipping
                ? 'Total (incluye envío)'
                : 'Total a pagar'),
            Text(
              Utils.formatPrice(UtilsVenta.totalWithShipping),
              style: const TextStyle(
                  color: Colores.secondaryColor, fontWeight: FontWeight.bold),
            ),
            if (UtilsVenta.hasServicios)
              Text(
                'Servicios y anticipos: ${Utils.formatPrice(UtilsVenta.serviciosTotal)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            if (UtilsVenta.hasShipping)
              Text(
                'Envío: ${Utils.formatPrice(UtilsVenta.shippingCost)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(cobroDeMas ? 'Cobro de más' : 'Debe por pagar'),
            Text(
              Utils.formatPrice(debePorPagar.value.abs()),
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
            if (cobroDeMas)
              const Text(
                'El pago excede el total',
                style: TextStyle(fontSize: 11, color: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  /// Fondo blanco en forma de pastilla para los selectores.
  Widget _pastilla({required double width, required Widget child, bool borde = false}) {
    return SizedBox(
      width: width,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: borde ? Border.all(color: Colors.grey.shade300) : null,
              boxShadow: borde
                  ? null
                  : [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: child,
          ),
        ],
      ),
    );
  }

  /// Texto de los selectores: el tema trae titleMedium en 30 pt y lo hacía
  /// enorme y encimado.
  TextStyle _estiloSelector(BuildContext context) =>
      (Theme.of(context).textTheme.bodyLarge ?? const TextStyle())
          .copyWith(fontSize: 15, color: Colores.textPrimary);

  Widget _cargandoPequeno() => const Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );

  Widget _aviso(String texto, Color color) => Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(texto, style: TextStyle(color: color, fontSize: 12)),
      );

  Widget _buildDropdownAndTextField({
    required BuildContext context,
    required String hintText,
    required String controlNameDropdown,
    required String controlNameTextField,
    required String controlNameCuenta,
    required String controlNameTerminal,
    Map<String, String Function(Object)>? validationMessages,
  }) {
    final enable = useState(false);
    // En pantallas anchas el 80% hacía la pastilla enorme: se acota a 520.
    final w80 = MediaQuery.of(context).size.width * 0.8;
    final fieldWidth = w80 > 520.0 ? 520.0 : w80;
    return Center(
      child: Column(
        children: [
          _pastilla(
            width: fieldWidth,
            child: ReactiveDropdownField<String>(
              validationMessages: validationMessages,
              formControlName: controlNameDropdown,
              style: _estiloSelector(context),
              isExpanded: true,
              decoration: InputDecoration(
                  alignLabelWithHint: true,
                  hintText: hintText,
                  hintStyle: _estiloSelector(context).copyWith(color: Colors.grey),
                  border: InputBorder.none),
              items: metodosDePago.map((String metodo) {
                return DropdownMenuItem<String>(
                  value: metodo,
                  child: Text(metodo, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (control) {
                form.control(controlNameTextField).markAsEnabled();
                enable.value = form.control(controlNameTextField).disabled;

                // Al cambiar el método se limpian cuenta y terminal
                form.control(controlNameCuenta).reset();
                form.control(controlNameTerminal).reset();

                // Con tarjeta (04 Crédito / 28 Débito) se pre-llena lo que
                // FALTA por pagar, no el total: en el 2º o 3º método se
                // cobraba dos o tres veces.
                final metodo = control.value ?? '';
                if (metodo.contains('04') || metodo.contains('28')) {
                  final restante = UtilsVenta.totalWithShipping -
                      sumaAnticipos(excepto: controlNameTextField);
                  form.control(controlNameTextField).value =
                      restante > 0 ? restante : 0.0;
                }
              },
            ),
          ),

          // Cuenta (01 Efectivo / 03 Transferencia) o terminal (04 / 28)
          ReactiveValueListenableBuilder<String?>(
            formControlName: controlNameDropdown,
            builder: (context, control, child) {
              final String? method = control.value;
              if (method == null) return const SizedBox.shrink();
              final esCuenta = method.contains('01') || method.contains('03');
              final esTarjeta = method.contains('04') || method.contains('28');
              if (!esCuenta && !esTarjeta) return const SizedBox.shrink();

              return BlocBuilder<PaymentInfoBloc, PaymentInfoState>(
                builder: (context, state) {
                  if (state is PaymentInfoLoading) return _cargandoPequeno();
                  if (state is PaymentInfoError) {
                    return _aviso(
                        'Error cargando ${esCuenta ? 'cuentas' : 'terminales'}: ${state.message}',
                        Colors.red);
                  }
                  if (state is! PaymentInfoLoaded) {
                    // Estado inicial: volver a pedir la información de pago
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<PaymentInfoBloc>().add(LoadPaymentInfoEvent());
                    });
                    return _cargandoPequeno();
                  }

                  if (esCuenta) {
                    if (state.cuentas.isEmpty) {
                      return _aviso('No hay cuentas disponibles', Colors.orange);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: _pastilla(
                        width: fieldWidth,
                        borde: true,
                        child: ReactiveDropdownField<String>(
                          formControlName: controlNameCuenta,
                          style: _estiloSelector(context),
                          isExpanded: true,
                          decoration: InputDecoration(
                              hintText: 'Selecciona Cuenta',
                              hintStyle:
                                  _estiloSelector(context).copyWith(color: Colors.grey),
                              border: InputBorder.none),
                          items: state.cuentas
                              .map((e) => DropdownMenuItem(
                                    value: e.id.toString(),
                                    child: Text(e.nombre,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  }

                  // Débito (28) no muestra las terminales de meses sin intereses
                  final terminales = method.contains('28')
                      ? state.terminales
                          .where((t) => !t.nombre.toUpperCase().contains('MSI'))
                          .toList()
                      : state.terminales;
                  if (terminales.isEmpty) {
                    return _aviso(
                        method.contains('28')
                            ? 'No hay terminales de débito disponibles'
                            : 'No hay terminales disponibles',
                        Colors.orange);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: _pastilla(
                      width: fieldWidth,
                      borde: true,
                      child: ReactiveDropdownField<String>(
                        formControlName: controlNameTerminal,
                        style: _estiloSelector(context),
                        isExpanded: true,
                        decoration: InputDecoration(
                            hintText: 'Selecciona Terminal',
                            hintStyle:
                                _estiloSelector(context).copyWith(color: Colors.grey),
                            border: InputBorder.none),
                        items: terminales
                            .map((e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(e.nombre,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 4.0),
          SizedBox(
            width: fieldWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ReactiveTextField(
                formControlName: controlNameTextField,
                validationMessages: validationMessages,
                // Traduce el texto con comas (36,980.00) al double del form.
                valueAccessor: MilesValueAccessor(),
                decoration: InputDecoration(
                    hintText: 'Anticipo o Pago',
                    helperText:
                        'Máximo ${Utils.formatPrice(maximoCapturable(controlNameTextField))}',
                    helperStyle: const TextStyle(fontSize: 11),
                    prefixIcon: const Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, left: 15.0, right: 5.0),
                      child: Text('\$', style: TextStyle(color: Colors.black)),
                    ),
                    suffixText: 'MXN',
                    contentPadding:
                        const EdgeInsets.only(top: 15.0, left: 15.0, right: 5.0),
                    alignLabelWithHint: true),
                keyboardType: TextInputType.number,
                // No deja teclear un importe que exceda lo que falta por pagar.
                inputFormatters: [
                  // Formato de miles en vivo (99,999,999.99)...
                  const MilesInputFormatter(),
                  // ...y tope de captura sobre el texto ya formateado.
                  LimiteImporteFormatter(
                    () => maximoCapturable(controlNameTextField),
                    onRechazado: (maximo) => _avisarLimite(context, maximo),
                  ),
                ],
                readOnly: enable.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ValueNotifier<bool> loading,
      ValueNotifier<double> debePorPagar) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BlocConsumer<PedidoVentaBloc, PedidoState>(
            listener: (context, state) {
              if (state is PedidoLoading) {
                loading.value = true;
              }
              if (state is PedidoDetalleLoaded) {
                loading.value = false;
                _enviando = false;
                debePorPagar.value = 0.0;

                ScaffoldMessenger.of(context).removeCurrentSnackBar();

                _showDownloadModal(
                  context,
                  state.pedido.pedidos,
                  state.pedido.pedidos,
                  state.username,
                );
                context
                    .read<ProductosTiendaBloc>()
                    .add(ClearProductoStateEvent());
                context.read<PedidoVentaBloc>().add(ClearPedidoStateEvent());
                context
                    .read<InventarioTiendaBloc>()
                    .add(ClearInventarioProductoEvent());
              } else if (state is PedidoError) {
                loading.value = false;
                _enviando = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return ElevatedButton.icon(
                onPressed: loading.value ? null : _submitForm,
                icon: const Icon(
                  PhosphorIconsLight.floppyDisk,
                  color: Colores.scaffoldBackgroundColor,
                ),
                label: Text(
                  loading.value ? 'ESPERE..' : 'GUARDAR',
                  style: TextStyle(
                      color: loading.value
                          ? Colores.secondaryColor
                          : Colores.scaffoldBackgroundColor),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.secondaryColor),
              );
            },
          ),
          ElevatedButton.icon(
            onPressed: _dialogCancel,
            icon: const Icon(PhosphorIconsLight.x, color: Colores.secondaryColor),
            label: const Text(
              'CANCELAR',
              style: TextStyle(color: Colores.secondaryColor),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Revisa que el método [n] traiga cuenta o terminal según su tipo.
  String? _faltaCuentaOTerminal(int n) {
    final metodo = form.control('metodoDePago$n').value as String?;
    if (metodo == null) return null;
    bool vacio(String c) => (form.control(c).value ?? '').toString().isEmpty;
    if ((metodo.contains('01') || metodo.contains('03')) && vacio('cuenta$n')) {
      return 'Método de Pago $n: Debe seleccionar una cuenta para $metodo';
    }
    if ((metodo.contains('04') || metodo.contains('28')) &&
        vacio('terminal$n')) {
      return 'Método de Pago $n: Debe seleccionar una terminal para $metodo';
    }
    return null;
  }

  void _error(String texto, {int segundos = 4}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: Colors.red,
        duration: Duration(seconds: segundos),
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (_enviando) return;
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }
    final metodo1 = form.control('metodoDePago1').value != null
        ? getMetodoDePagoId(form.control('metodoDePago1').value)
        : 0;
    final metodo2 = form.control('metodoDePago2').value != null
        ? getMetodoDePagoId(form.control('metodoDePago2').value)
        : 0;
    final metodo3 = form.control('metodoDePago3').value != null
        ? getMetodoDePagoId(form.control('metodoDePago3').value)
        : 0;
    final String observaciones = form.control('observaciones').value ?? '';

    final double anticipoPago = _anticipoDe('anticipoPago1');
    final double anticipoPago2 = _anticipoDe('anticipoPago2');
    final double anticipoPago3 = _anticipoDe('anticipoPago3');
    final entregado = form.control('entregado').value ? 1 : 0;

    final falta = _faltaCuentaOTerminal(1) ??
        _faltaCuentaOTerminal(2) ??
        _faltaCuentaOTerminal(3);
    if (falta != null) {
      _error(falta);
      return;
    }

    final totalAnticipos = anticipoPago + anticipoPago2 + anticipoPago3;
    final totalAPagar = UtilsVenta.totalWithShipping;

    // El cobro nunca puede exceder el total del ticket.
    if (totalAnticipos - totalAPagar > _tolerancia) {
      _error(
          'El pago (${Utils.formatPrice(totalAnticipos)}) no puede ser mayor '
          'al total a pagar (${Utils.formatPrice(totalAPagar)}). '
          'Sobran ${Utils.formatPrice(totalAnticipos - totalAPagar)}.',
          segundos: 5);
      return;
    }
    if (anticipoPago < 0 || anticipoPago2 < 0 || anticipoPago3 < 0) {
      _error('Los importes de pago no pueden ser negativos.');
      return;
    }

    // Banco, cuenta y terminal de cada pago, desde lo que trajo el bloc
    final info = context.read<PaymentInfoBloc>().state;
    CuentaModel? cuentaDe(String? id) {
      if (id == null || info is! PaymentInfoLoaded) return null;
      for (final c in info.cuentas) {
        if (c.id == id) return c;
      }
      return null;
    }

    TerminalModel? terminalDe(String? id) {
      if (id == null || info is! PaymentInfoLoaded) return null;
      for (final t in info.terminales) {
        if (t.id == id) return t;
      }
      return null;
    }

    final cuenta1 = cuentaDe(form.control('cuenta1').value);
    final terminal1 = terminalDe(form.control('terminal1').value);
    final cuenta2 = cuentaDe(form.control('cuenta2').value);
    final terminal2 = terminalDe(form.control('terminal2').value);
    final cuenta3 = cuentaDe(form.control('cuenta3').value);
    final terminal3 = terminalDe(form.control('terminal3').value);

    final data = {
      'descripcio': widget.dataCliente['nombre'] ?? '',
      'correo': widget.dataCliente['correo'] ?? '',
      'direccion': widget.dataCliente['direccion'] ?? '',
      'telefono': widget.dataCliente['telefono'] ?? '',
      'id_metodopago': metodo1,
      // banco/cuenta salen de la cuenta o de la terminal; terminal solo con tarjeta
      'banco1': cuenta1?.banco ?? terminal1?.banco ?? '',
      'cuenta1': cuenta1?.cuenta ?? terminal1?.cuenta ?? '',
      'terminal1': terminal1?.id ?? '',
      // El servicio y la ruta del envío van también en las observaciones.
      'observaciones': [
        observaciones,
        if (UtilsVenta.hasShipping) 'Envío: ${UtilsVenta.shippingObserva}',
      ].where((t) => t.trim().isNotEmpty).join(' | '),
      'estatus': widget.estadoPedido,
      'anticipo': anticipoPago,
      'anticipo2': anticipoPago2,
      'anticipo3': anticipoPago3,
      'total_pagar': totalAPagar,
      'entregado': entregado,
      'id_metodopago2': metodo2,
      'banco2': cuenta2?.banco ?? terminal2?.banco ?? '',
      'cuenta2': cuenta2?.cuenta ?? terminal2?.cuenta ?? '',
      'terminal2': terminal2?.id ?? '',
      'id_metodopago3': metodo3,
      'banco3': cuenta3?.banco ?? terminal3?.banco ?? '',
      'cuenta3': cuenta3?.cuenta ?? terminal3?.cuenta ?? '',
      'terminal3': terminal3?.id ?? '',
    };

    _enviando = true;
    context.read<PedidoVentaBloc>().add(
        PedidoAddEvent(data: data, products: UtilsVenta.partidasConEnvio));
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
                PhosphorIconsLight.warning,
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
                FocusScope.of(context).unfocus();
                context
                    .read<ProductosTiendaBloc>()
                    .add(ClearProductoStateEvent());
                context.read<PedidoVentaBloc>().add(ClearPedidoStateEvent());
                context
                    .read<InventarioTiendaBloc>()
                    .add(ClearInventarioProductoEvent());
                HomeRoute().go(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDownloadModal(
      BuildContext context, String pedido, String userName, sendToWhatsApp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Se genero el Ticket exitosamente '),
          content: Row(
            children: [
              const Text('TICKET: ', style: TextStyle(fontSize: 15)),
              Text(
                pedido,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colores.secondaryColor,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colores.scaffoldBackgroundColor),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  // Limpiar todo el formulario para el siguiente ticket,
                  // incluidas cuentas y terminales
                  for (final c in form.controls.keys) {
                    if (c == 'pendienteFinDeExpo' || c == 'entregado') continue;
                    form.control(c).reset();
                  }
                  Navigator.of(context).pop();
                  HomeRoute().go(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
