import 'package:appexpflutter_update/features/historial/presentation/blocs/historial/historial_bloc.dart';
/* import 'package:appexpflutter_update/features/shared/widgets/custom_dropdownbutton.dart';
import 'package:auto_size_text/auto_size_text.dart'; */
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final textFieldValue = useState<String>('');
    // final dropdownValue = useState<String>(listSearch.first);

    useEffect(() {
      controller.addListener(() {
        textFieldValue.value = controller.text;
      });
      return null;
    }, [controller]);

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
                FontAwesomeIcons.userGroup,
                color: Colores.secondaryColor,
              ),
              onChanged: (value) {
                dropdownValue.value = value!;
              },
              icon: const FaIcon(
                FontAwesomeIcons.diagramNext,
                color: Colores.secondaryColor,
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
              style: const TextStyle(
                color: Colores.secondaryColor,
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
                context.read<HistorialBloc>().add(GetHistorialCotiza(
                    parameter: textFieldValue.value, search: 'cotización'));
              },
              decoration: InputDecoration(
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.red,
                        ))
                    : null,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.search,
                    color: Colores.secondaryColor,
                  ),
                ),
                hintText: 'Buscar...',
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
