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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: isMultiSelectMode!
            ? isSelected!
                ? LinearGradient(
                    colors: [
                      Colores.secondaryColor.withValues(alpha: 0.2),
                      Colores.primaryColor.withValues(alpha: 0.1),
                    ],
                  )
                : null
            : null,
        color: isMultiSelectMode! && isSelected! ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected! 
              ? Colores.secondaryColor.withValues(alpha: 0.5)
              : Colores.dividerColor.withValues(alpha: 0.5),
          width: isSelected! ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected!
                ? Colores.secondaryColor.withValues(alpha: 0.2)
                : Colores.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () => onLongPress(producto),
          onTap: () => onTap(producto),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colores.primaryColor.withValues(alpha: 0.1),
          highlightColor: Colores.primaryColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
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
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 300),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colores.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/no-image.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.producto,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colores.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Clave: ${producto.producto1}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colores.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Existencia: $existencia',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: existencia! > 0 
                                  ? Colores.successColor 
                                  : Colores.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Medidas: ${producto.medidas}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colores.textSecondary,
                            ),
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
