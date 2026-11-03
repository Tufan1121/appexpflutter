import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
import 'package:appexpflutter_update/features/reportes/presentation/screen/widgets/ventas_barras_chart.dart';
import 'package:flutter/material.dart';

const Color _kColorOk = Color(0xFF1F9D55);

/// Avance contra la meta de la expo, igual que la tarjeta de la lista de
/// pedidos web. Va arriba de las pestañas para verse en ambas gráficas.
class MetaAvanceCard extends StatelessWidget {
  final MetaExpoEntity meta;

  const MetaAvanceCard({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final m = meta;
    final desglose =
        'Pedidos ${fmtMoney.format(m.pedidos)} · Tickets ${fmtMoney.format(m.puntoventa)}';
    const titulo = TextStyle(
        fontSize: 12.5, fontWeight: FontWeight.w600, color: kColorTextoTenue);
    const numero = TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: kColorTexto);
    const sub = TextStyle(fontSize: 12, color: kColorTextoTenue);

    final List<Widget> contenido;
    if (m.meta > 0) {
      final pct = (m.alcanzado / m.meta * 100).clamp(0.0, 100.0);
      final lleno = pct >= 100;
      contenido = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Avance de la meta', style: titulo),
                  const SizedBox(height: 2),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: fmtMoney.format(m.alcanzado), style: numero),
                    TextSpan(
                        text: '  de ${fmtMoney.format(m.meta)}',
                        style: const TextStyle(
                            fontSize: 13, color: kColorTextoTenue)),
                  ])),
                ],
              ),
            ),
            Text('${m.porcentaje.toStringAsFixed(m.porcentaje % 1 == 0 ? 0 : 1)}%',
                style: numero),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                Container(color: const Color(0xFFF1F4F9)),
                FractionallySizedBox(
                  widthFactor: pct / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: lleno ? _kColorOk : kColorPedidos,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${m.falta > 0 ? 'Faltan ${fmtMoney.format(m.falta)}' : '¡Meta alcanzada!'} · $desglose',
          style: sub,
        ),
      ];
    } else {
      contenido = [
        const Text('Venta de la expo', style: titulo),
        const SizedBox(height: 2),
        Text(fmtMoney.format(m.alcanzado), style: numero),
        const SizedBox(height: 4),
        Text('Sin meta configurada para esta expo · $desglose', style: sub),
      ];
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kColorBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: contenido,
        ),
      ),
    );
  }
}
