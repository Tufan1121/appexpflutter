import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:precios/domain/entities/producto_entity.dart';

class ProductoCard extends StatelessWidget {
  final ProductoEntity producto;
  final int existencia;
  final GestureTapCallback onTap;
  final String? imagen;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.existencia,
    required this.onTap,
    this.imagen,
  });

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
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colores.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagen != null && imagen!.isNotEmpty)
            Stack(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: FadeInImage(
                    image: NetworkImage(imagen!),
                    placeholder: const AssetImage('assets/loaders/loading.gif'),
                    width: double.infinity,
                    height: 140,
                    fadeInDuration: const Duration(milliseconds: 300),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              children: [
                AutoSizeText(
                  producto.producto,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colores.textPrimary,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                _buildInfoRow('Clave', producto.producto1),
                _buildInfoRow('Existencia en Bodegas', existencia.toString()),
                _buildInfoRow('Medidas', producto.medidas),
                _buildInfoRow('Precio Lista',
                    Utils.formatPrice(producto.precio1.toDouble())),
                _buildCompositionRow(
                    'Composición', '${producto.compo1} ${producto.compo2}'),
                const SizedBox(height: 4),
                SizedBox(
                  width: 180,
                  child: ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    title: AutoSizeText(
                      'Promoción',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colores.secondaryColor,
                          fontSize: 18),
                      maxLines: 1,
                    ),
                    children: [
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: promociones.length,
                          itemBuilder: (context, index) {
                            final precio = promociones[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
          ),
          Expanded(
            child: AutoSizeText(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.end,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          AutoSizeText(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AutoSizeText(
              value,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
            ),
          ),
        ],
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
