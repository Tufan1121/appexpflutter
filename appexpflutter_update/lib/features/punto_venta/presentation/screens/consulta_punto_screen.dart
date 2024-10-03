import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/custom_list_tile.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/popover.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/consulta/consulta_bloc.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class PuntoVentaConsultaScreen extends HookWidget {
  const PuntoVentaConsultaScreen({super.key});

  String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dateControllerDesde = useTextEditingController();
    final dateControllerHasta = useTextEditingController();
    final selectedDateDesde = useState<DateTime>(DateTime.now());
    final selectedDateHasta = useState<DateTime>(DateTime.now());

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        context.read<ConsultaBloc>().add(ClearTicketsEvent());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: CustomAppBar(
            onPressed: () {
              context.read<ConsultaBloc>().add(ClearTicketsEvent());
              Navigator.pop(context);
            },
            title: 'CONSULTA',
          ),
        ),
        body: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: BackgroundPainter(),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                _fechaTextField(dateControllerDesde, dateControllerHasta,
                    context, selectedDateDesde, selectedDateHasta),
                Expanded(
                  child: BlocBuilder<ConsultaBloc, ConsultaState>(
                    builder: (context, state) {
                      if (state is ConsultaLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colores.secondaryColor,
                          ),
                        );
                      } else if (state is ConsultaLoaded) {
                        return ListView.builder(
                          itemCount: state.tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = state.tickets[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  onLongPress: () => homeModalButtom(
                                    height: 160,
                                    context: context,
                                    child: ListView(
                                      children: [
                                        CustomListTile(
                                            text: 'VISUALIZAR',
                                            assetPathIcon:
                                                'assets/iconos/cliente nuevo - rosa gris.png',
                                            onTap: () {}),
                                        const Divider(),
                                        CustomListTile(
                                            text: 'CANCELAR',
                                            assetPathIcon:
                                                'assets/iconos/cliente existente - rosa gris.png',
                                            onTap: () {})
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    'Ticket: ${ticket.documen}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text('Fecha: ${ticket.fechaEmi}'),
                                      Text(
                                          'Total: ${Utils.formatPrice(ticket.total)}'),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is ConsultaError) {
                        return Center(
                          child: Text(state.message),
                        );
                      } else {
                        return const Center(
                          child: Text('Seleccione un rango de fechas'),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fechaTextField(
      TextEditingController dateControllerDesde,
      TextEditingController dateControllerHasta,
      BuildContext context,
      ValueNotifier<DateTime> selectedDateDesde,
      ValueNotifier<DateTime> selectedDateHasta) {
    Future selectDate(ValueNotifier<DateTime> selectedDate,
        TextEditingController controller) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );
      if (picked != null) {
        selectedDate.value = picked;
        controller.text = DateFormat("dd/MM/yyyy").format(picked);
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: TextField(
                    controller: dateControllerDesde,
                    readOnly: true,
                    onTap: () =>
                        selectDate(selectedDateDesde, dateControllerDesde),
                    decoration: InputDecoration(
                      labelText: 'Fecha desde',
                      suffixIcon: const Icon(Icons.calendar_today),
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: dateControllerHasta,
                    readOnly: true,
                    onTap: () =>
                        selectDate(selectedDateHasta, dateControllerHasta),
                    decoration: InputDecoration(
                      labelText: 'Fecha hasta',
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 14),
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0),
          child: ElevatedButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colores.secondaryColor,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  elevation: 4,
                  shadowColor: Colores.colorSeed),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    color: Colores.scaffoldBackgroundColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Buscar',
                    style: TextStyle(color: Colores.scaffoldBackgroundColor),
                  ),
                ],
              ),
              onPressed: () {
                if (dateControllerDesde.text.isEmpty ||
                    dateControllerHasta.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Por favor, ingrese ambas fechas.'),
                    ),
                  );
                } else {
                  context.read<ConsultaBloc>().add(GetSalesTicketsEvent(
                      fechaInicio: formatDate(selectedDateDesde.value),
                      fechaFin: formatDate(selectedDateHasta.value)));
                }
              }),
        ),
      ],
    );
  }

  Future<dynamic> homeModalButtom(
      {required BuildContext context, required Widget child, double? height}) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          child: Container(
            height: height,
            color: Colores.scaffoldBackgroundColor,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
