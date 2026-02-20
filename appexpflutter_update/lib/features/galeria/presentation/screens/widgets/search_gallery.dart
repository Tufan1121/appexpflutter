import 'package:appexpflutter_update/features/galeria/presentation/blocs/galeria/galeria_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';

class SearchGallery extends HookWidget {
  const SearchGallery({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final textFieldValue = useState<String>('');
    final debounceTimer = useState<Timer?>(null);

    useEffect(() {
      controller.addListener(() {
        textFieldValue.value = controller.text;
      });
      return null;
    }, [controller]);

    // Limpiar el timer cuando el widget se desmonte
    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    void onSearchChanged(String value) {
      // Cancelar el timer anterior si existe
      debounceTimer.value?.cancel();

      // Crear un nuevo timer con un delay de 500ms
      debounceTimer.value = Timer(const Duration(milliseconds: 500), () {
        if (value.trim().isEmpty) {
          context.read<GaleriaBloc>().add(const GetGaleriaEvent());
        } else {
          context.read<GaleriaBloc>().add(GetGaleriaEvent(descripcion: value.trim()));
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
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
                onChanged: onSearchChanged,
                onSubmitted: (value) {
                  // Cancelar el debounce y ejecutar inmediatamente
                  debounceTimer.value?.cancel();
                  if (value.trim().isEmpty) {
                    context.read<GaleriaBloc>().add(const GetGaleriaEvent());
                  } else {
                    context.read<GaleriaBloc>().add(GetGaleriaEvent(descripcion: value.trim()));
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.search,
                      color: Colores.secondaryColor,
                    ),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            debounceTimer.value?.cancel();
                            controller.clear();
                            context
                                .read<GaleriaBloc>()
                                .add(const GetGaleriaEvent());
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                          ))
                      : null,
                  hintText: 'Busca una colección',
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
          ),
        ],
      ),
    );
  }
}
