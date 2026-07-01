import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/product_shipping_info.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/shipping_quote_modal_v2.dart';

/// Botón con etiqueta "Cotizar envío" para las consultas de inventario y el
/// scan de precios. Se coloca al pie de la card (no como overlay sobre la
/// imagen) y usa un color de contraste distinto al del visualizador y al de
/// "Ver +Detalle" para no confundirse entre sí.
///
/// A diferencia de la sesión de ventas, aquí es solo una **consulta**: abre el
/// mismo `ShippingQuoteModalV2` con un único producto y, al seleccionar una
/// tarifa, simplemente se cierra el modal (no se guarda envío en el pedido).
class CotizarEnvioButton extends StatelessWidget {
  final ProductShippingInfo product;

  const CotizarEnvioButton({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colores.infoColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ShippingQuoteModalV2.show(
          context: context,
          products: [product],
          // Consulta: al elegir una tarifa solo se cierra el modal.
          onShippingSelected: (_, __, ___, ____) {},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_shipping_outlined,
                  color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Cotizar envío',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
