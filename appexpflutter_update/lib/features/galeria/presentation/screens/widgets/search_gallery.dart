import 'package:appexpflutter_update/features/galeria/presentation/blocs/galeria/galeria_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchGallery extends HookWidget {
  const SearchGallery({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final textFieldValue = useState<String>('');

    useEffect(() {
      controller.addListener(() {
        textFieldValue.value = controller.text;
      });
      return null;
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
                style: const TextStyle(
                  color: Colores.secondaryColor,
                  fontSize: 16,
                ),
                obscureText: false,
                keyboardType: TextInputType.text,
                onSubmitted: (value) => context
                    .read<GaleriaBloc>()
                    .add(GetGaleriaEvent(descripcion: value.trim())),
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
