import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';

class ListaProductosTiendaCard extends HookWidget {
  const ListaProductosTiendaCard({
    super.key,
    required this.producto,
    this.isSelected,
    this.existencia,
    this.isMultiSelectMode,
    required this.onLongPress,
    required this.onTap,
  });

  final ProductoExpoEntity producto;
  final bool? isSelected;
  final int? existencia;
  final bool? isMultiSelectMode;
  final Function(ProductoExpoEntity) onLongPress;
  final Function(ProductoExpoEntity) onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        clipBehavior: Clip.hardEdge,
        color: isMultiSelectMode!
            ? isSelected!
                ? Colores.secondaryColor.withOpacity(0.5)
                : null
            : null,
        child: InkWell(
          onLongPress: () => onLongPress(producto),
          onTap: () => onTap(producto),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FadeInImage(
                      placeholder:
                          const AssetImage('assets/loaders/loading.gif'),
                      image: producto.pathima1 != null &&
                              producto.pathima1!.isNotEmpty
                          ? NetworkImage(
                              'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1 ?? '')}',
                            )
                          : const AssetImage('assets/images/no-image.jpg')
                              as ImageProvider,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 300),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/no-image.jpg',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
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
                          const SizedBox(height: 4),
                          Text(
                            'Existencia: $existencia',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Medidas: ${producto.medidas}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          _buildPriceCheckbox(
                            context: context,
                            label: 'Precio de Lista',
                            price: producto.precio1.toDouble(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCheckbox({
    required BuildContext context,
    required String label,
    required double price,
  }) {
    return Column(
      children: [
        AutoSizeText(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        AutoSizeText(
          Utils.formatPrice(price),
          maxLines: 2,
        ),
      ],
    );
  }
}
