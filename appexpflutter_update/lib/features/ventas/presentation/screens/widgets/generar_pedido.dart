import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/layout_screens.dart';

class GenerarPedidoScreen extends StatefulHookWidget {
  const GenerarPedidoScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final isEntregado = useState(false);

    final isPendienteFinDeExpo = useState(true);
    final size = MediaQuery.of(context).size;
    final scrollController = useScrollController();

    void toggleCheckbox(String controlName) {
      if (controlName == 'entregado') {
        isEntregado.value = true;
        isPendienteFinDeExpo.value = false;
        form.control('entregado').value = true;
        form.control('pendienteFinDeExpo').value = false;
      } else if (controlName == 'pendienteFinDeExpo') {
        isEntregado.value = false;
        isPendienteFinDeExpo.value = true;
        form.control('entregado').value = false;
        form.control('pendienteFinDeExpo').value = true;
      }
    }

    // void resetScrollPosition() {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     scrollController.animateTo(
    //       0.0,
    //       duration: const Duration(milliseconds: 300),
    //       curve: Curves.easeOut,
    //     );
    //   });
    // }

    // useEffect(() {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     resetScrollPosition();
    //   });
    //   return null;
    // }, []);

    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'GENERAR PEDIDO',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: size.height - 93, // 80 los dos sizebox
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
                            const Text(
                              'DM24-7645B',
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16.0),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total a pagar'),
                                    Text(
                                      '\$990.00',
                                      style: TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Debe por pagar'),
                                    Text(
                                      '\$990.00',
                                      style: TextStyle(
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
