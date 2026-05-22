import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/producto_card_data.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/producto_result_card.dart';
import 'package:flutter/material.dart';

/// Grid/lista responsivo de resultados de búsqueda con **alto variable**:
/// cada card se dimensiona a su contenido (la cantidad de pills de medida
/// varía por producto), así nada queda recortado.
///
/// - < 600 px: 1 columna → `ListView` (cada card a su alto natural).
/// - 600–900 px: 2 columnas → `Wrap`.
/// - 900–1280 px: 3 columnas → `Wrap`.
/// - ≥ 1280 px: 4 columnas → `Wrap`.
///
/// `Wrap` permite alto variable por card (a diferencia de
/// `GridView + childAspectRatio` que forzaba un alto fijo y cortaba el
/// contenido). Cada tarjeta usa `ProductoResultCard`.
class ProductosResultGrid extends StatelessWidget {
  final List<ProductoCardData> productos;

  const ProductosResultGrid({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        int columns;
        if (w >= 1280) {
          columns = 4;
        } else if (w >= 900) {
          columns = 3;
        } else if (w >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        if (columns == 1) {
          // 1 columna → ListView: cada card crece a su contenido.
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: productos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                ProductoResultCard(data: productos[index]),
          );
        }

        // Multi-columna → Wrap con cards de ancho fijo y alto intrínseco.
        const spacing = 12.0;
        final cardWidth = (w - 24 - (columns - 1) * spacing) / columns;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final p in productos)
                SizedBox(
                  width: cardWidth,
                  child: ProductoResultCard(data: p),
                ),
            ],
          ),
        );
      },
    );
  }
}
