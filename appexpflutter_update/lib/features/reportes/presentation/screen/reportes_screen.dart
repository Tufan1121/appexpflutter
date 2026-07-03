import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/presentation/bloc/reportes_bloc.dart';
import 'package:appexpflutter_update/features/reportes/presentation/screen/widgets/vendedor_donut_chart.dart';
import 'package:appexpflutter_update/features/reportes/presentation/screen/widgets/meta_gauge_chart.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:appexpflutter_update/features/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportesScreen extends HookWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateControllerDesde = useTextEditingController();
    final dateControllerHasta = useTextEditingController();
    final selectedDateDesde = useState<DateTime?>(null);
    final selectedDateHasta = useState<DateTime?>(null);
    final tabController = useTabController(initialLength: 3);

    Future<void> selectDate(ValueNotifier<DateTime?> selectedDate,
        TextEditingController controller) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );
      if (picked != null) {
        selectedDate.value = picked;
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      }
    }

    void buscar() {
      final fi = selectedDateDesde.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedDateDesde.value!)
          : null;
      final ff = selectedDateHasta.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedDateHasta.value!)
          : null;
      context
          .read<ReportesBloc>()
          .add(GetReportesPedidosEvent(fechaini: fi, fechafin: ff));
      context
          .read<ReportesBloc>()
          .add(GetReportesTicketsEvent(fechaini: fi, fechafin: ff));
      context
          .read<ReportesBloc>()
          .add(GetReportesVendedorEvent(fechaini: fi, fechafin: ff));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: CustomAppBar(
          onPressed: () => HomeRoute().push(context),
          title: 'REPORTES',
        ),
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: BackgroundPainter(),
          ),
          Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dateControllerDesde,
                            readOnly: true,
                            onTap: () => selectDate(
                                selectedDateDesde, dateControllerDesde),
                            decoration: InputDecoration(
                              labelText: 'Fecha desde',
                              isDense: true,
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: dateControllerHasta,
                            readOnly: true,
                            onTap: () => selectDate(
                                selectedDateHasta, dateControllerHasta),
                            decoration: InputDecoration(
                              labelText: 'Fecha hasta',
                              isDense: true,
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: buscar,
                          icon: const Icon(Icons.search),
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Colores.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Por día'),
                  Tab(text: 'Por vendedor'),
                  Tab(text: 'Meta'),
                ],
              ),
              Expanded(
                child: BlocBuilder<ReportesBloc, ReportesState>(
                  builder: (context, state) {
              if (state is ReportesLoading) {
                return const Center(
                    child: LoadingIndicator());
              } else if (state is ReportesLoaded) {
                final listaPedidos = state.salesPedidos;
                final listaTickets = state.salesTickets;

                final allDates = <String>{};
                for (var pedido in listaPedidos) {
                  allDates.add(pedido.fecham);
                }
                for (var ticket in listaTickets) {
                  allDates.add(ticket.fecham);
                }

                // Ordena las fechas
                final orderedDates = allDates.toList()..sort();

                // Genera las listas con datos alineados
                final alignedPedidos = orderedDates.map((date) {
                  final pedido = listaPedidos.firstWhere(
                      (p) => p.fecham == date,
                      orElse: () =>
                          SalesPedidosEntity(fecham: date, gtotal: 0));
                  return pedido;
                }).toList();

                final alignedTickets = orderedDates.map((date) {
                  final ticket = listaTickets.firstWhere(
                      (t) => t.fecham == date,
                      orElse: () =>
                          SalesTicketsEntity(fecham: date, gtotal: 0));
                  return ticket;
                }).toList();

                // Calcula la suma total de cada serie
                final totalPedidos =
                    listaPedidos.fold<int>(0, (sum, item) => sum + item.gtotal.toInt());
                final totalTickets = listaTickets.fold<int>(
                    0, (sum, item) => sum + item.gtotal.toInt());

                // Calcula la suma de Pedidos y Tickets por fecha
                final Map<String, int> sumasPorFecha = {};

                for (var pedido in listaPedidos) {
                  sumasPorFecha[pedido.fecham] = pedido.gtotal.toInt();
                }

                for (var ticket in listaTickets) {
                  if (sumasPorFecha.containsKey(ticket.fecham)) {
                    sumasPorFecha[ticket.fecham] =
                        sumasPorFecha[ticket.fecham]! + ticket.gtotal.toInt();
                  } else {
                    sumasPorFecha[ticket.fecham] = ticket.gtotal.toInt();
                  }
                }

                final totalGlobal = totalPedidos + totalTickets;
                final numDias = orderedDates.length;

                // Formato compacto para ejes y etiquetas ($1.2M, $850K)
                final NumberFormat compactCurrency =
                    NumberFormat.compactCurrency(
                  locale: 'en_US',
                  symbol: '\$',
                  decimalDigits: 1,
                );

                // ===== Tab 1: gráfica por día =====
                final Widget chartPorDia = (totalGlobal <= 0)
                    ? const Center(
                        child: Text(
                          'No hay ventas en el rango seleccionado',
                          style: TextStyle(
                            color: Colores.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelRotation: -45,
                          labelIntersectAction:
                              AxisLabelIntersectAction.multipleRows,
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0.5),
                          majorTickLines: const MajorTickLines(size: 0),
                          axisLabelFormatter:
                              (AxisLabelRenderDetails details) {
                            // details.text viene como yyyy-MM-dd -> dd/MM
                            final parts = details.text.split('-');
                            final short = parts.length == 3
                                ? '${parts[2]}/${parts[1]}'
                                : details.text;
                            return ChartAxisLabel(
                                short, const TextStyle(fontSize: 10));
                          },
                        ),
                        primaryYAxis: NumericAxis(
                          numberFormat: compactCurrency,
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                          majorGridLines: MajorGridLines(
                            width: 0.6,
                            color: Colors.grey.shade300,
                            dashArray: const <double>[4, 4],
                          ),
                          labelStyle: const TextStyle(fontSize: 11),
                        ),
                        title: ChartTitle(
                          text:
                              'Ventas por día\nTotal: ${currencyFormat.format(totalGlobal)}',
                          textStyle: const TextStyle(
                            color: Colores.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        legend: const Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          activationMode: ActivationMode.singleTap,
                          tooltipSettings: const InteractiveTooltip(
                            format: 'series.name : point.y',
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          canShowMarker: true,
                          header: '',
                          format: 'point.x : point.y',
                        ),
                        series: [
                          StackedColumnSeries<SalesPedidosEntity, String>(
                            dataSource: alignedPedidos,
                            xValueMapper: (SalesPedidosEntity data, _) =>
                                data.fecham,
                            yValueMapper: (SalesPedidosEntity data, _) =>
                                data.gtotal,
                            name: 'Pedidos',
                            color: const Color(0xFF42A5F5),
                            width: 0.7,
                            spacing: 0.15,
                          ),
                          StackedColumnSeries<SalesTicketsEntity, String>(
                            dataSource: alignedTickets,
                            xValueMapper: (SalesTicketsEntity data, _) =>
                                data.fecham,
                            yValueMapper: (SalesTicketsEntity data, _) =>
                                data.gtotal,
                            name: 'Punto de Venta',
                            color: const Color(0xFF66BB6A),
                            width: 0.7,
                            spacing: 0.15,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ],
                        annotations: <CartesianChartAnnotation>[
                          // Total por día encima de cada barra (solo si caben)
                          if (numDias <= 12)
                            for (var entry in sumasPorFecha.entries)
                              CartesianChartAnnotation(
                                widget: Text(
                                  compactCurrency.format(entry.value),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colores.secondaryColor,
                                  ),
                                ),
                                coordinateUnit: CoordinateUnit.point,
                                x: entry.key,
                                y: entry.value,
                                verticalAlignment: ChartAlignment.far,
                              ),
                        ],
                      ),
                    ),
                  ),
                );

                // ===== Tab 2: gráfica por vendedor (dona) =====
                final listaVendedor = state.salesVendedor;
                final Widget chartPorVendedor = listaVendedor.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay ventas por vendedor en el rango',
                          style: TextStyle(
                            color: Colores.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : VendedorDonutChart(
                        data: listaVendedor,
                        currencyFormat: currencyFormat,
                      );

                // ===== Tab 3: avance hacia la meta =====
                final metaExpo = state.metaExpo;
                final Widget chartMeta = metaExpo == null
                    ? const Center(
                        child: LoadingIndicator(),
                      )
                    : MetaGaugeChart(
                        meta: metaExpo,
                        currencyFormat: currencyFormat,
                      );

                return TabBarView(
                  controller: tabController,
                  children: [chartPorDia, chartPorVendedor, chartMeta],
                );
              } else if (state is ReportesError) {
                return Center(child: Text(state.message));
              }

              return Container();
            },
          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
