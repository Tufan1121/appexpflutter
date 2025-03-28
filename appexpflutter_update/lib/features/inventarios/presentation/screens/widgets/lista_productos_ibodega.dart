import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
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
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildPriceCheckbox(
                      context: context,
                      label: 'Precio de Lista',
                      price: producto.precio1.toDouble(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        width: 180,
                        child: ExpansionTile(
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          title: AutoSizeText(
                            'Promoción',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colores.secondaryColor,
                            ),
                            maxLines: 1,
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
