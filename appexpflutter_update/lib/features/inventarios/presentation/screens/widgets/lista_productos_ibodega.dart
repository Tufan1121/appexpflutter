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
                          'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1)}',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Bodega 1: ${producto.bodega1.toInt()}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Bodega 2: ${producto.bodega2.toInt()}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Bodega 3: ${producto.bodega3.toInt()}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Bodega 4: ${producto.bodega4.toInt()}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 4),
                Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPriceCheckbox(
                          context: context,
                          label: 'Precio de Lista',
                          price: producto.precio1.toDouble(),
                        ),
                        const SizedBox(width: 10),
                        _buildPriceCheckbox(
                          context: context,
                          label: 'Precio de Expo',
                          price: producto.precio2.toDouble(),
                        ),
                        const SizedBox(width: 10),
                        _buildPriceCheckbox(
                          context: context,
                          label: 'Precio Mayoreo',
                          price: producto.precio3.toDouble(),
                        ),
                      ],
                    ),
                  ),
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
