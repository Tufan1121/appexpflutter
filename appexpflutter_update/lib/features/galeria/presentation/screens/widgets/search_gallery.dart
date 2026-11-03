import 'dart:async';

import 'package:appexpflutter_update/config/upper_case_text_formatter.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/galeria/galeria_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SearchGallery extends HookWidget {
  const SearchGallery({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final textFieldValue = useState<String>('');

    // Busca mientras se escribe, medio segundo después de la última tecla
    final debounce = useRef<Timer?>(null);
    useEffect(() {
      controller.addListener(() {
        if (controller.text == textFieldValue.value) return;
        textFieldValue.value = controller.text;
        debounce.value?.cancel();
        debounce.value = Timer(const Duration(milliseconds: 500), () {
          if (!context.mounted) return;
          final texto = controller.text.trim();
          context.read<GaleriaBloc>().add(texto.isEmpty
              ? const GetGaleriaEvent()
              : GetGaleriaEvent(descripcion: texto));
        });
      });
      return () => debounce.value?.cancel();
    }, [controller]);

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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
                obscureText: false,
                keyboardType: TextInputType.text,
                inputFormatters: [UpperCaseTextFormatter()],
                onSubmitted: (value) => context
                    .read<GaleriaBloc>()
                    .add(GetGaleriaEvent(descripcion: value.trim())),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      PhosphorIconsLight.magnifyingGlass,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
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
                  hintText: 'Colección, color, composición u origen',
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
