import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/product_shipping_info.dart';
import 'package:appexpflutter_update/features/cotizador_envio/presentation/widgets/cotizar_envio_button.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/visualizar_tapete.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';

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
            Stack(
              children: [
                GestureDetector(
                    onTap: onTap,
                    child: FadeInImage(
                      image: NetworkImage(
                        imagen!,
                      ),
                      placeholder:
                          const AssetImage('assets/loaders/loading.gif'),
                      width: double.infinity,
                      height: 220,
                      fadeInDuration: const Duration(milliseconds: 300),
                      fit: BoxFit.cover,
                    )),
                // Botón "Ver en mi espacio" (visualizador). Solo si el producto
                // trae `surface`; si viene vacío no se muestra.
                if ((producto.surface ?? '').trim().isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => VisualizarTapete.iniciar(
                          context,
                          tapeteUrl: producto.pathima1,
                          anchoM: producto.ancho,
                          largoM: producto.largo,
                          superficie: producto.surface ?? '',
                          titulo: [
                            producto.descripcio,
                            producto.diseno,
                            producto.medidas,
                          ].where((e) => e.trim().isNotEmpty).join(' · '),
                        ),
                        child: Tooltip(
                          message: VisualizarTapete.etiquetaSuperficie(
                              producto.surface),
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(
                                VisualizarTapete.iconoSuperficie(
                                    producto.surface),
                                color: Colors.white,
                                size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: CotizarEnvioButton(
                    product: ProductShippingInfo.fromDimensions(
                      productKey: producto.producto1,
                      productName: [
                        producto.descripcio,
                        producto.medidas,
                      ].where((e) => e.trim().isNotEmpty).join(' · '),
                      largop: producto.largop,
                      anchop: producto.anchop,
                      altop: producto.altop,
                      peso: producto.peso,
                      largoM: producto.largo,
                      anchoM: producto.ancho,
                    ),
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
}
