import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Paleta fija para que el color de la leyenda coincida con su rebanada.
const List<Color> _kPalette = <Color>[
  Color(0xFF42A5F5),
  Color(0xFF66BB6A),
  Color(0xFFFFA726),
  Color(0xFFAB47BC),
  Color(0xFFEF5350),
  Color(0xFF26C6DA),
  Color(0xFFFFCA28),
  Color(0xFF8D6E63),
  Color(0xFF7E57C2),
  Color(0xFF26A69A),
];

/// Dona de ventas por vendedor. Al tocar una rebanada, el centro muestra el
/// desglose de ese vendedor (Pedidos vs Punto de Venta).
class VendedorDonutChart extends HookWidget {
  final List<SalesVendedorEntity> data;
  final NumberFormat currencyFormat;

  const VendedorDonutChart({
    super.key,
    required this.data,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final selected = useState<int?>(null);
    final total = data.fold<double>(0, (s, v) => s + v.gtotal);

    final SalesVendedorEntity? sel =
        (selected.value != null && selected.value! < data.length)
            ? data[selected.value!]
            : null;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: SfCircularChart(
            palette: _kPalette,
            title: ChartTitle(
              text: 'Ventas por vendedor\nTotal: ${currencyFormat.format(total)}',
              textStyle: const TextStyle(
                color: Colores.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              // Evita que el tap en la leyenda oculte la rebanada (default de
              // Syncfusion); aquí el tap solo selecciona.
              toggleSeriesVisibility: false,
              // Cada item muestra el total del vendedor y al tocarlo lo
              // selecciona (mismo efecto que tocar la rebanada).
              legendItemBuilder: (name, series, point, index) {
                final v = data[index];
                final isSel = selected.value == index;
                return GestureDetector(
                  onTap: () => selected.value = index,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSel
                          ? Colores.secondaryColor.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _kPalette[index % _kPalette.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_ordinal(index + 1)}  ${v.vendedor}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              currencyFormat.format(v.gtotal),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colores.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            onSelectionChanged: (SelectionArgs args) {
              selected.value = args.pointIndex;
            },
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: _centerLabel(sel),
              ),
            ],
            series: <CircularSeries>[
              DoughnutSeries<SalesVendedorEntity, String>(
                dataSource: data,
                xValueMapper: (d, _) => d.vendedor,
                yValueMapper: (d, _) => d.gtotal,
                radius: '80%',
                innerRadius: '62%',
                explode: true,
                explodeIndex: selected.value,
                dataLabelMapper: (d, _) => d.vendedor,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  overflowMode: OverflowMode.shift,
                  textStyle: TextStyle(fontSize: 10),
                  connectorLineSettings:
                      ConnectorLineSettings(type: ConnectorType.curve),
                ),
                selectionBehavior: SelectionBehavior(enable: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Posición del ranking en español abreviado: 1ro, 2do, 3ro, ...
  String _ordinal(int n) {
    switch (n) {
      case 1:
        return '1ro';
      case 2:
        return '2do';
      case 3:
        return '3ro';
      case 4:
        return '4to';
      case 5:
        return '5to';
      case 6:
        return '6to';
      case 7:
        return '7mo';
      case 8:
        return '8vo';
      case 9:
        return '9no';
      default:
        return '$n°';
    }
  }

  Widget _centerLabel(SalesVendedorEntity? sel) {
    if (sel == null) {
      return const SizedBox(
        width: 110,
        child: Text(
          'Toca una rebanada para ver el detalle',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sel.vendedor,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colores.secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(sel.gtotal),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Pedidos: ${currencyFormat.format(sel.pedidos)}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF42A5F5)),
          ),
          Text(
            'P. Venta: ${currencyFormat.format(sel.puntoventa)}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF66BB6A)),
          ),
        ],
      ),
    );
  }
}
