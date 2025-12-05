import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:precios/domain/entities/producto_entity.dart';

class ListaProductosIBodegaCard extends HookWidget {
  const ListaProductosIBodegaCard({
    super.key,
    required this.producto,
    this.isSelected,
    this.existencia,
    this.onTap,
  });
  final ProductoEntity producto;
  final bool? isSelected;
  final int? existencia;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final List<double> promociones = [
      producto.precio8.toDouble(),
      if (producto.precio9 != null) producto.precio9!.toDouble(),
      producto.precio4.toDouble(),
      if (producto.precio10 != null) producto.precio10!.toDouble(),
      producto.precio5.toDouble(),
      producto.precio6.toDouble(),
      producto.precio7.toDouble(),
    ];

    final descuentos = [
      '-20%',
      '-25%',
      '-30%',
      '-35%',
      '-40%',
      '-50%',
      '-70%',
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected == true
                ? Colores.primaryColor
                : Colores.dividerColor.withValues(alpha: 0.2),
            width: isSelected == true ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected == true
                  ? Colores.primaryColor.withValues(alpha: 0.15)
                  : Colores.primaryColor.withValues(alpha: 0.06),
              blurRadius: isSelected == true ? 20 : 15,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colores.dividerColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/loaders/loading.gif',
                          image:
                              'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1)}',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/no-image.jpg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.producto,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: Colores.successColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Existencia: $existencia',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colores.successColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Medidas: ${producto.medidas}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colores.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colores.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bodega 1: ${producto.bodega1.toInt()}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colores.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Bodega 2: ${producto.bodega2.toInt()}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colores.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bodega 3: ${producto.bodega3.toInt()}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colores.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Bodega 4: ${producto.bodega4.toInt()}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colores.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colores.primaryColor.withValues(alpha: 0.1),
                            Colores.accentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildPriceCheckbox(
                        context: context,
                        label: 'Precio Lista',
                        price: producto.precio1.toDouble(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colores.dividerColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          title: Row(
                            children: [
                              const Icon(
                                Icons.local_offer_outlined,
                                size: 18,
                                color: Colores.secondaryColor,
                              ),
                              const SizedBox(width: 6),
                              AutoSizeText(
                                'Promoción',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colores.secondaryColor,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                          children: [
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: promociones.length,
                                itemBuilder: (context, index) {
                                  final precio = promociones[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: _buildPriceCheckbox(
                                      context: context,
                                      label: descuentos[index],
                                      price: precio,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
    return Row(
      children: [
        AutoSizeText(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        AutoSizeText(
          Utils.formatPrice(price),
          maxLines: 2,
        ),
      ],
    );
  }
}
