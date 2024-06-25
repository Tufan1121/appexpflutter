import 'package:appexpflutter_update/config/utils.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/layout_screens.dart';

class GenerarPedidoScreen extends StatefulHookWidget {
  const GenerarPedidoScreen({
    super.key,
    required this.productos,
    required this.idCliente,
  });
  final List<ProductoEntity> productos;
  final int idCliente;

  @override
  State<GenerarPedidoScreen> createState() => _GenerarPedidoScreenState();
}

class _GenerarPedidoScreenState extends State<GenerarPedidoScreen> {
  final form = FormGroup({
    'metodoDePago1': FormControl<String>(),
    'anticipoPago1': FormControl<double>(disabled: true),
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
    '04 Tarjeta de Crédito o Débito'
  ];

  final totalAPagar = UtilsVenta.total;

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
