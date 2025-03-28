import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/inventario_tienda/inventario_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/pedido/pedido_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../config/theme/app_theme.dart';

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

  final totalAPagar = UtilsVenta.total;

  void updateDebePorPagar(FormGroup form, ValueNotifier<double> debePorPagar) {
    final anticipoPago1 = form.control('anticipoPago1').value ?? 0.0;
    final anticipoPago2 = form.control('anticipoPago2').value ?? 0.0;
    final anticipoPago3 = form.control('anticipoPago3').value ?? 0.0;
    final totalAnticipo = anticipoPago1 + anticipoPago2 + anticipoPago3;
    debePorPagar.value = totalAPagar - totalAnticipo;
  }

  @override
  Widget build(BuildContext context) {
    final debePorPagar = useState(UtilsVenta.total);
    final scrollController = useScrollController();
    final loading = useState(false);

    useEffect(() {
      form
          .control('anticipoPago1')
          .valueChanges
          .listen((_) => updateDebePorPagar(form, debePorPagar));
      form
          .control('anticipoPago2')
          .valueChanges
          .listen((_) => updateDebePorPagar(form, debePorPagar));
      form
          .control('anticipoPago3')
          .valueChanges
          .listen((_) => updateDebePorPagar(form, debePorPagar));

      return null;
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
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ReactiveForm(
                            formGroup: form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16.0),
                                _buildTotales(debePorPagar),
                                const SizedBox(height: 10.0),
                                _buildDropdownAndTextField(
                                  context: context,
                                  hintText: 'Selecciona Método de Pago 1',
                                  controlNameDropdown: 'metodoDePago1',
                                  controlNameTextField: 'anticipoPago1',
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
                                ),
                                const SizedBox(height: 10.0),
                                _buildDropdownAndTextField(
                                  context: context,
                                  hintText: 'Selecciona Método de Pago 3',
                                  controlNameDropdown: 'metodoDePago3',
                                  controlNameTextField: 'anticipoPago3',
                                ),
                                const SizedBox(height: 10.0),
                                ReactiveTextField(
                                  formControlName: 'observaciones',
                                  decoration: const InputDecoration(
                                      labelText: 'Observaciones'),
                                  maxLines: 3, // Permitir múltiples líneas
                                  keyboardType: TextInputType.multiline,
                                  validationMessages: {
                                    ValidationMessage.required: (error) =>
                                        'Este campo es requerido'
                                  },
                                ),
                                const SizedBox(height: 20.0),
                                // Botones de acción dentro del formulario
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotales(ValueNotifier<double> debePorPagar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total a pagar'),
            Text(
              Utils.formatPrice(UtilsVenta.total),
              style: const TextStyle(
                  color: Colors.purple, fontWeight: FontWeight.bold),
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
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownAndTextField({
    required BuildContext context,
    required String hintText,
    required String controlNameDropdown,
    required String controlNameTextField,
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
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ]),
              ),
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
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.04,
              ),
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
                  Icons.save,
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
            icon: const Icon(Icons.close, color: Colores.secondaryColor),
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
      final String observaciones = form.control('observaciones').value ?? '';

      final double anticipoPago = form.control('anticipoPago1').value ?? 0.0;
      final double anticipoPago2 = form.control('anticipoPago2').value ?? 0.0;
      final double anticipoPago3 = form.control('anticipoPago3').value ?? 0.0;
      final entregado = form.control('entregado').value ? 1 : 0;

      final data = {
        'descripcio': widget.dataCliente['nombre'],
        'correo': widget.dataCliente['correo'],
        'direccion': widget.dataCliente['direccion'],
        'telefono': widget.dataCliente['telefono'],
        'id_metodopago': metodo1,
        'observaciones': observaciones,
        'estatus': widget.estadoPedido,
        'anticipo': anticipoPago.toInt(),
        'anticipo2': anticipoPago2.toInt(),
        'anticipo3': anticipoPago3.toInt(),
        'total_pagar': totalAPagar.toInt(),
        'entregado': entregado,
        'id_metodopago2': metodo2,
        'id_metodopago3': metodo3.toString(),
      };

      context.read<PedidoVentaBloc>().add(
          PedidoAddEvent(data: data, products: UtilsVenta.listProductsOrder));
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
                  // opcion 1
                  // getpdf.downloadPDF(pdfUrl, nombrePdf);
                  // opcion 2
                  // _openPDF(pdfUrl);
                  // sendToWhatsApp(pdfUrl, widget.dataCliente['telefono'],
                  //     userName, nombrePdf);
                  form.control('metodoDePago1').reset();
                  form.control('metodoDePago2').reset();
                  form.control('metodoDePago3').reset();
                  form.control('observaciones').reset();
                  form.control('anticipoPago1').reset();
                  form.control('anticipoPago2').reset();
                  form.control('anticipoPago3').reset();
                  form.control('entregado').reset();
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
