import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Medidor circular de avance hacia la meta de la expo.
class MetaGaugeChart extends StatelessWidget {
  final MetaExpoEntity meta;
  final NumberFormat currencyFormat;

  const MetaGaugeChart({
    super.key,
    required this.meta,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final m = meta.meta;
    if (m <= 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Aún no se ha definido la meta de esta expo.\n'
            'Captúrala en la tabla "expos" (columna meta).',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colores.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final pct = meta.alcanzado / m * 100;
    final pctClamped = pct.clamp(0, 100).toDouble();
    final Color color = pct >= 100
        ? const Color(0xFF2E7D32)
        : pct >= 70
            ? const Color(0xFF66BB6A)
            : pct >= 40
                ? const Color(0xFFFFA726)
                : const Color(0xFFEF5350);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
          child: Column(
            children: [
              const Text(
                'Avance hacia la meta',
                style: TextStyle(
                  color: Colores.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: SfCircularChart(
                  annotations: <CircularChartAnnotation>[
                    CircularChartAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const Text(
                            'de la meta',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                  series: <CircularSeries>[
                    RadialBarSeries<_GaugeData, String>(
                      dataSource: [_GaugeData('Meta', pctClamped)],
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      maximumValue: 100,
                      radius: '100%',
                      innerRadius: '68%',
                      cornerStyle: CornerStyle.bothCurve,
                      trackColor: Colors.grey.shade200,
                      pointColorMapper: (d, _) => color,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _row('Meta', currencyFormat.format(meta.meta),
                  Colores.secondaryColor),
              _row('Alcanzado', currencyFormat.format(meta.alcanzado), color),
              _row('Falta', currencyFormat.format(meta.falta),
                  Colors.grey.shade700),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugeData {
  final String label;
  final double value;
  _GaugeData(this.label, this.value);
}
