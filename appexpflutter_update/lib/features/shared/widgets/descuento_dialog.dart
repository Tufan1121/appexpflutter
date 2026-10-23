import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';

/// Porcentaje máximo de descuento autorizado, tanto general como por partida.
const double kDescuentoMaximo = 40;

/// Máximo % que se puede aplicar encima de [otroPct] sin que el descuento
/// combinado de una partida pase de [kDescuentoMaximo]. Los descuentos son
/// acumulables (1 - p)(1 - g), no se suman: con 20% de partida el general
/// puede llegar a 25%, no a 20%.
double descuentoDisponible(double otroPct) {
  final restante =
      (1 - (1 - kDescuentoMaximo / 100) / (1 - otroPct / 100)) * 100;
  // Redondeo hacia abajo a 2 decimales para no rebasar el tope por centavos.
  return (restante * 100 + 1e-6).floorToDouble().clamp(0, kDescuentoMaximo * 100) /
      100;
}

/// Lee el % capturado en el campo de descuento por partida y lo limita a
/// [maximo]. Si se pasó, corrige el texto del campo y avisa al usuario.
double leerDescuentoPartida(
  BuildContext context,
  TextEditingController controller,
  double maximo,
) {
  final pct = double.tryParse(controller.text) ?? 0;
  if (pct <= maximo) return pct < 0 ? 0 : pct;

  final tope = maximo.truncateToDouble() == maximo
      ? maximo.toStringAsFixed(0)
      : maximo.toStringAsFixed(2);
  controller.value = TextEditingValue(
    text: tope,
    selection: TextSelection.collapsed(offset: tope.length),
  );
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(maximo < kDescuentoMaximo
          ? 'Con el descuento general, esta partida admite máximo $tope% '
              '(total ${kDescuentoMaximo.toStringAsFixed(0)}%)'
          : 'El descuento máximo es de $tope%'),
      duration: const Duration(milliseconds: 2000),
    ));
  return maximo;
}

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
  // Tope para el general; baja cuando ya hay descuentos por partida.
  double maximoPct = kDescuentoMaximo,
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
          // Tolerancia de redondeo al capturar por monto.
          final valido = valor > 0 && pct > 0 &&
              (esPorcentaje
                  ? valor <= maximoPct
                  : valor / subtotalActual * 100 <= maximoPct + 0.01);
          final textoMaximo = maximoPct.truncateToDouble() == maximoPct
              ? maximoPct.toStringAsFixed(0)
              : maximoPct.toStringAsFixed(2);

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
                  Text(
                    'El descuento máximo es de $textoMaximo%'
                    '${esPorcentaje ? '' : ' (${Utils.formatPrice(subtotalActual * maximoPct / 100)})'}'
                    '${maximoPct < kDescuentoMaximo ? ' porque ya hay descuento por partida; '
                        'el total por partida no puede pasar de ${kDescuentoMaximo.toStringAsFixed(0)}%' : ''}.',
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
