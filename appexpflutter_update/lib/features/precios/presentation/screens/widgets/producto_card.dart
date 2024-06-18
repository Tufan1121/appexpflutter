import 'package:appexpflutter_update/config/utils.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ProductoCard extends StatelessWidget {
  final ProductoEntity producto;
  final double existencia;
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
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagen != null && imagen!.isNotEmpty)
            GestureDetector(
                onTap: onTap,
                child: FadeInImage(
                  image: NetworkImage(
                    imagen!,
                  ),
                  placeholder: const AssetImage('assets/loaders/loading.gif'),
                  width: double.infinity,
                  height: 200,
                  fadeInDuration: const Duration(milliseconds: 300),
                  fit: BoxFit.cover,
                )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              children: [
                AutoSizeText(
                  producto.producto,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                _buildInfoRow('Clave', producto.producto1),
                _buildInfoRow('Existencia en Bodegas', existencia.toString()),
                _buildInfoRow('Medidas', producto.medidas),
                _buildInfoRow('Precio Lista',
                    Utils.formatPrice(producto.precio1.toDouble())),
                _buildInfoRow('Precio Expo',
                    Utils.formatPrice(producto.precio2.toDouble())),
                _buildInfoRow('Precio Mayoreo',
                    Utils.formatPrice(producto.precio3.toDouble())),
                _buildCompositionRow(
                    'Composición', '${producto.compo1} ${producto.compo2}'),
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
}
