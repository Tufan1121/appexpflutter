import 'package:appexpflutter_update/features/historial/presentation/blocs/historial/historial_bloc.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class PuntoVentaConsultaScreen extends HookWidget {
  const PuntoVentaConsultaScreen({super.key});

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
        context.read<HistorialBloc>().add(ClearHistorialEvent());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: CustomAppBar(
            onPressed: () {
              context.read<HistorialBloc>().add(ClearHistorialEvent());
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
                _fechadeNacimientoTextField(
                    dateControllerDesde,
                    dateControllerHasta,
                    context,
                    selectedDateDesde,
                    selectedDateHasta),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fechadeNacimientoTextField(
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextField(
                controller: dateControllerDesde,
                readOnly: true,
                onTap: () => selectDate(selectedDateDesde, dateControllerDesde),
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
                onTap: () => selectDate(selectedDateHasta, dateControllerHasta),
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
    );
  }
}
