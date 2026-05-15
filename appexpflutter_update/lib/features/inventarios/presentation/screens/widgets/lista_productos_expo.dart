import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:inventarios/domain/entities/producto_expo_entity.dart';

class ListaProductosExpo extends HookWidget {
  const ListaProductosExpo({
    super.key,
    required this.producto,
    this.onTap,
  });
  final ProductoExpoEntity producto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showPrice = useState(false);

    return GestureDetector(
      onTap: onTap,
      child: ClipRect(
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FadeInImage.assetNetwork(
                      placeholder: 'assets/loaders/loading.gif',
                      image:
                          'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(producto.pathima1)}',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/no-image.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        // Envuelve la columna en SingleChildScrollView
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.producto,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Clave: ${producto.producto1}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'origen: ${producto.origen}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Medidas: ${producto.medidas}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            AutoSizeText(
                              'Almacen: ${producto.almacen} - ${producto.desalmacen}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            AutoSizeText(
                              'Existencia: ${producto.hm}',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildPriceToggle(
                  context: context,
                  price: producto.precio1.toDouble(),
                  expanded: showPrice.value,
                  onToggle: () => showPrice.value = !showPrice.value,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceToggle({
    required BuildContext context,
    required double price,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      child: Row(
        children: [
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 22,
          ),
          const SizedBox(width: 8),
          if (expanded)
            AutoSizeText(
              Utils.formatPrice(price),
              maxLines: 2,
            ),
        ],
      ),
    );
  }
}
