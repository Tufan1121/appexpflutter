import 'package:appexpflutter_update/features/historial/presentation/blocs/historial/historial_bloc.dart';
/* import 'package:appexpflutter_update/features/shared/widgets/custom_dropdownbutton.dart';
import 'package:auto_size_text/auto_size_text.dart'; */
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchHistorial extends HookWidget {
  SearchHistorial({
    super.key,
  });

  final listSearch = [
    'Buscar por pedido',
    'Buscar por sesión',
    'Buscar por cotización'
  ];

  /// Pide las cotizaciones de la tienda; [texto] filtra por nombre del
  /// cliente o folio (vacío = todas).
  void _buscar(BuildContext context, String texto) {
    context
        .read<HistorialBloc>()
        .add(GetHistorialCotiza(parameter: texto, search: 'cotización'));
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final textFieldValue = useState<String>('');
    // final dropdownValue = useState<String>(listSearch.first);

    useEffect(() {
      controller.addListener(() {
        if (controller.text == textFieldValue.value) return;
        textFieldValue.value = controller.text;
        // Filtra mientras se escribe (el bloc espera a que se deje de teclear)
        _buscar(context, controller.text.trim());
      });
      return null;
    }, [controller]);

    // Al entrar: la lista completa
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _buscar(context, '');
      });
      return null;
    }, []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          /* SizedBox(
            width: 250,
            child: CustomDropdownButton<String>(
              value: dropdownValue.value,
              hint: 'Selecciona como buscar',
              styleHint: const TextStyle(fontSize: 15),
              prefixIcon: const FaIcon(
                PhosphorIconsLight.users,
                color: Theme.of(context).colorScheme.primary,
              ),
              onChanged: (value) {
                dropdownValue.value = value!;
              },
              icon: const FaIcon(
                PhosphorIconsLight.caretDown,
                color: Theme.of(context).colorScheme.primary,
              ),
              items: listSearch.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: AutoSizeText(
                    value,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
            ),
          ), */
          const SizedBox(height: 10),
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2.0, 5.0),
                )
              ],
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
              obscureText: false,
              keyboardType: TextInputType.text,
              onChanged: (value) {},
              onSubmitted: (value) {
                /*     if (textFieldValue.value.isNotEmpty) {
                  switch (dropdownValue.value) {
                    case 'Buscar por pedido':
                      context.read<HistorialBloc>().add(GetHistorialPedido(
                          parameter: textFieldValue.value, search: 'pedido'));
                      break;
                    case 'Buscar por sesión':
                      context.read<HistorialBloc>().add(GetHistorialSesion(
                          parameter: textFieldValue.value, search: 'sesión'));
                      break;

                    case 'Buscar por cotización':
                      context.read<HistorialBloc>().add(GetHistorialCotiza(
                          parameter: textFieldValue.value,
                          search: 'cotización'));
                      break;
                  } */
                _buscar(context, value.trim());
              },
              decoration: InputDecoration(
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                        },
                        icon: const Icon(
                          PhosphorIconsLight.x,
                          color: Colors.red,
                        ))
                    : null,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    PhosphorIconsLight.magnifyingGlass,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                hintText: 'Filtrar por cliente o folio',
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.only(left: 12.0, top: 5, bottom: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
