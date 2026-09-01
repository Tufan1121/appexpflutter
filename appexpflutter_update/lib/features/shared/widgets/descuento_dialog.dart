import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';

/// Resultado del diálogo de descuento general.
class DescuentoAutorizado {
  const DescuentoAutorizado({required this.porcentaje, this.quitar = false});

  /// Porcentaje final a aplicar (0–100). Si el usuario capturó un monto, aquí
  /// ya viene convertido a porcentaje sobre el subtotal actual.
  final double porcentaje;

  /// true cuando el usuario pidió quitar el descuento.
  final bool quitar;
}

/// Diálogo para capturar un descuento general autorizado, por porcentaje o por
/// monto. El prorrateo entre partidas es automático: el porcentaje resultante
/// se aplica al precio unitario de cada partida, así el detalle y el total
/// quedan siempre cuadrados sin cálculos manuales.
Future<DescuentoAutorizado?> mostrarDialogoDescuento(
  BuildContext context, {
  required double subtotalActual,
  required double descuentoActualPct,
}) {
  return showDialog<DescuentoAutorizado>(
    context: context,
    builder: (context) {
      bool esPorcentaje = true;
      final controller = TextEditingController(
        text: descuentoActualPct > 0
            ? descuentoActualPct.toStringAsFixed(
                descuentoActualPct.truncateToDouble() == descuentoActualPct
                    ? 0
                    : 2)
            : '',
      );

      return StatefulBuilder(
        builder: (context, setState) {
          final valor = double.tryParse(controller.text) ?? 0;
          // Convertir a porcentaje para la vista previa.
          double pct;
          if (esPorcentaje) {
            pct = valor.clamp(0, 100).toDouble();
          } else {
            pct = subtotalActual > 0
                ? (valor / subtotalActual * 100).clamp(0, 100).toDouble()
                : 0;
          }
          final montoDescuento = subtotalActual * pct / 100;
          final nuevoSubtotal = subtotalActual - montoDescuento;
          final valido = valor > 0 &&
              (esPorcentaje ? valor <= 100 : valor <= subtotalActual + 0.01);

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.percent, color: Colores.secondaryColor),
                SizedBox(width: 8),
                Text('Descuento general'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de captura: porcentaje o monto
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Porcentaje %'),
                        selected: esPorcentaje,
                        selectedColor:
                            Colores.secondaryColor.withOpacity(0.25),
                        onSelected: (_) =>
                            setState(() => esPorcentaje = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Monto \$'),
                        selected: !esPorcentaje,
                        selectedColor:
                            Colores.secondaryColor.withOpacity(0.25),
                        onSelected: (_) =>
                            setState(() => esPorcentaje = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixText: esPorcentaje ? null : '\$ ',
                    suffixText: esPorcentaje ? '%' : 'MXN',
                    hintText: esPorcentaje
                        ? 'Ej. 10 = 10% de descuento'
                        : 'Ej. 500 = \$500 de descuento',
                  ),
                ),
                const SizedBox(height: 12),
                Text('Subtotal actual: ${Utils.formatPrice(subtotalActual)}',
                    style: const TextStyle(fontSize: 13)),
                if (valido) ...[
                  Text(
                    'Descuento (${pct.toStringAsFixed(2)}%): '
                    '-${Utils.formatPrice(montoDescuento)}',
                    style: const TextStyle(fontSize: 13, color: Colors.green),
                  ),
                  Text(
                    'Nuevo subtotal: ${Utils.formatPrice(nuevoSubtotal)}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ] else if (valor > 0)
                  const Text(
                    'El descuento no puede exceder el subtotal.',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                const SizedBox(height: 4),
                const Text(
                  'Se prorratea automáticamente entre todas las partidas.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              if (descuentoActualPct > 0)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(
                      const DescuentoAutorizado(porcentaje: 0, quitar: true)),
                  child: const Text('QUITAR DESCUENTO',
                      style: TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCELAR',
                    style: TextStyle(color: Colores.secondaryColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.secondaryColor),
                onPressed: valido
                    ? () => Navigator.of(context)
                        .pop(DescuentoAutorizado(porcentaje: pct))
                    : null,
                child: const Text('APLICAR',
                    style:
                        TextStyle(color: Colores.scaffoldBackgroundColor)),
              ),
            ],
          );
        },
      );
    },
  );
}
