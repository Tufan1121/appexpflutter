import 'package:appexpflutter_update/config/utils.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/pedido/pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/layout_screens.dart';

class GenerarPedidoScreen2 extends StatefulHookWidget {
  // const GenerarPedidoScreen({
  //   super.key,
  //   required this.productos,
  //   required this.idCliente,
  // });
  const GenerarPedidoScreen2({
    super.key,
  });

  @override
  State<GenerarPedidoScreen2> createState() => _GenerarPedidoScreenState();
}

class _GenerarPedidoScreenState extends State<GenerarPedidoScreen2> {
  final List<ProductoEntity> productos = [
    ProductoEntity(
        producto: 'MATRIX 01CAFE1.80 X 1.20',
        producto1: 'A-10167-U',
        descripcio: 'LOGAN 01 CAFE',
        diseno: 'Moderno',
        medidas: '2x2',
        largo: 2.0,
        ancho: 2.0,
        precio1: 11999,
        precio2: 8460,
        precio3: 7200,
        pathima1: '',
        pathima2: '',
        pathima3: '',
        pathima4: '',
        pathima5: '',
        pathima6: '',
        desa: 0,
        color1: 'Café',
        color2: '',
        unidad: 'Pieza',
        compo1: 'Algodón',
        compo2: 'Poliéster',
        lava1: 'Lavar a mano',
        lava2: 'No usar lejía',
        origenn: 'México',
        fecha: DateTime.now(),
        cunidad: '',
        ccodigosat: '',
        precio4: 0,
        precio5: 0,
        precio6: 0,
        precio7: 0,
        precio8: 0,
        descrip: '',
        bodega1: 10,
        bodega2: 5,
        bodega3: 8,
        bodega4: 7),
    ProductoEntity(
        producto: 'MATRIX 01CAFE3.80 X 2.20',
        producto1: 'A-10167-F',
        descripcio: 'SOFA 02 AZUL',
        diseno: 'Clásico',
        medidas: '3x3',
        largo: 3.0,
        ancho: 3.0,
        precio1: 19999,
        precio2: 14960,
        precio3: 13200,
        pathima1: '',
        pathima2: '',
        pathima3: '',
        pathima4: '',
        pathima5: '',
        pathima6: '',
        desa: 0,
        color1: 'Azul',
        color2: '',
        unidad: 'Pieza',
        compo1: 'Cuero',
        compo2: '',
        lava1: 'Limpiar con paño húmedo',
        lava2: 'No exponer al sol',
        origenn: 'España',
        fecha: DateTime.now(),
        cunidad: '',
        ccodigosat: '',
        precio4: 0,
        precio5: 0,
        precio6: 0,
        precio7: 0,
        precio8: 0,
        descrip: '',
        bodega1: 3,
        bodega2: 2,
        bodega3: 1,
        bodega4: 1),
    // Agrega más productos según sea necesario
  ];
  final int idCliente = 124;
  final form = FormGroup({
    'metodoDePago1': FormControl<String>(validators: [
      Validators.required,
    ]),
    'anticipoPago1': FormControl<double>(disabled: true),
    'metodoDePago2': FormControl<String>(),
    'anticipoPago2': FormControl<double>(disabled: true),
    'metodoDePago3': FormControl<String>(),
    'anticipoPago3': FormControl<double>(disabled: true),
    'observaciones': FormControl<String>(validators: [
      Validators.required,
    ]),
    'entregado': FormControl<bool>(value: false),
    'pendienteFinDeExpo': FormControl<bool>(value: true),
  });
  final List<String> metodosDePago = [
    '01 Efectivo',
    '02 Cheque Nominativo',
    '03 Transferencia Electrónica',
    '04 Tarjeta de Crédito o Débito'
  ];

  final list = [
    'Pendiente Pago (Anticipo)',
    'Pagado Foráneo',
    'Pagado (Recoger en tienda)'
  ];

  int getMetodoDePagoId(String metodo) {
    return metodosDePago.indexOf(metodo) + 1;
  }

  int getEstadoPedidoPagoId(String metodo) {
    return list.indexOf(metodo) + 1;
  }

  final totalAPagar = 990.0;

  @override
  Widget build(BuildContext context) {
    final isEntregado = useState(false);

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
      titleScreen: 'GENERAR PEDIDO',
      child: Column(
        children: [
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
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SizedBox(
                        height: size.height * 0.95,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text(
                            //   'DM24-7645B',
                            //   style: TextStyle(
                            //       color: Colors.pink,
                            //       fontWeight: FontWeight.bold),
                            // ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total a pagar'),
                                    Text(
                                      Utils.formatPrice(totalAPagar),
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
                            ),
                            const SizedBox(height: 10.0),
                            buildDropdownAndTextField(
                              context: context,
                              hintText: 'Selecciona Método de Pago 2',
                              controlNameDropdown: 'metodoDePago2',
                              controlNameTextField: 'anticipoPago2',
                            ),
                            const SizedBox(height: 10.0),
                            buildDropdownAndTextField(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (form.valid) {
                                      // Maneja el envío del formulario
                                      final metodo1 =
                                          form.control('metodoDePago1').value !=
                                                  null
                                              ? getMetodoDePagoId(form
                                                  .control('metodoDePago1')
                                                  .value)
                                              : null;
                                      final metodo2 =
                                          form.control('metodoDePago2').value !=
                                                  null
                                              ? getMetodoDePagoId(form
                                                  .control('metodoDePago2')
                                                  .value)
                                              : null;
                                      final metodo3 =
                                          form.control('metodoDePago3').value !=
                                                  null
                                              ? getMetodoDePagoId(form
                                                  .control('metodoDePago3')
                                                  .value)
                                              : null;
                                      final String observaciones =
                                          form.control('observaciones').value;

                                      final double anticipoPago =
                                          form.control('anticipoPago1').value ??
                                              0.0;
                                      final double anticipoPago2 =
                                          form.control('anticipoPago2').value ??
                                              0.0;
                                      final double anticipoPago3 =
                                          form.control('anticipoPago3').value ??
                                              0.0;
                                      final estadoPedido =
                                          getEstadoPedidoPagoId(list[0]);

                                      print(
                                          'debe por pagar: ${debePorPagar.value}');

                                      final data = {
                                        'id_cliente': idCliente,
                                        'id_metodopago': metodo1,
                                        'observaciones': observaciones,
                                        'estatus': estadoPedido,
                                        'anticipo': anticipoPago,
                                        'anticipo2': anticipoPago2,
                                        'anticipo3': anticipoPago3,
                                        'total_pagar': totalAPagar
                                      };
                                      Map<String, dynamic> data2 = {};

                                      for (final producto in productos) {
                                        data2 = {
                                          'id_pedido': 1,
                                          'clave': producto.producto1,
                                          'clave2': producto.producto,
                                          'cantidad': 1.0,
                                          'precio': 2230
                                        };
                                      }
                                      // context.read<PedidoBloc>().add(PedidoAddEvent(data: data));
                                      print('PEDIDO $data');
                                      print('PEDIDO DETALLE: $data2');
                                    } else {
                                      form.markAllAsTouched();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colores.scaffoldBackgroundColor,
                                  ),
                                  label: const Text(
                                    'GUARDAR',
                                    style: TextStyle(
                                        color: Colores.scaffoldBackgroundColor),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colores.secondaryColor),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    form.reset();
                                  },
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
  }) {
    final enable = useState(false);
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 45,
            width: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2.0, 5.0),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ReactiveDropdownField<String>(
                  formControlName: controlNameDropdown,
                  decoration: InputDecoration(
                      hintText: hintText, border: InputBorder.none),
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
            ),
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            height: 45,
            width: 300,
            child: ReactiveTextField(
              formControlName: controlNameTextField,
              decoration: const InputDecoration(
                hintText: 'Anticipo o Pago',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 5.0),
                  child: Text('\$', style: TextStyle(color: Colors.black)),
                ),
                suffixText: 'MXN',
              ),
              keyboardType: TextInputType.number,
              readOnly: enable.value,
            ),
          ),
        ],
      ),
    );
  }
}
