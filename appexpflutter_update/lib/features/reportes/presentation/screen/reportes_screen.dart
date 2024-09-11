import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/presentation/bloc/reportes_bloc.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
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
          BlocBuilder<ReportesBloc, ReportesState>(
            builder: (context, state) {
              if (state is ReportesLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colores.secondaryColor,
                ));
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
                    listaPedidos.fold<int>(0, (sum, item) => sum + item.gtotal);
                final totalTickets = listaTickets.fold<int>(
                    0, (sum, item) => sum + item.gtotal.toInt());

                // Calcula la suma de Pedidos y Tickets por fecha
                final Map<String, int> sumasPorFecha = {};

                for (var pedido in listaPedidos) {
                  sumasPorFecha[pedido.fecham] = pedido.gtotal;
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

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.currency(
                          locale: 'en_US',
                          symbol: '\$',
                          decimalDigits: 0,
                        ),
                        maximum:
                            totalGlobal > 400000 ? (totalGlobal * 0.5) : 400000,
                      ),
                      title: ChartTitle(
                          text:
                              'Sales Pedidos y Tickets \n total: ${currencyFormat.format(totalPedidos + totalTickets)}',
                          textStyle:
                              const TextStyle(color: Colores.secondaryColor)),
                      legend: const Legend(isVisible: true),
                      onTooltipRender: (TooltipArgs args) {
                        final List<String> seriesNames = ['Pedidos', 'Tickets'];
                        final int seriesIndex = args.seriesIndex!.toInt();
                        args.text =
                            ' ${seriesNames[seriesIndex]}\n ${args.dataPoints![args.pointIndex!.toInt()].x} : ${currencyFormat.format(args.dataPoints![args.pointIndex!.toInt()].y)}';
                      },
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        canShowMarker: true,
                        header: '', // Esto elimina el encabezado.
                        format:
                            'point.x : point.y', // Esto solo muestra la fecha y el valor de gtotal.
                      ),
                      series: [
                        ColumnSeries<SalesPedidosEntity, String>(
                          dataSource: alignedPedidos,
                          xValueMapper: (SalesPedidosEntity data, _) =>
                              data.fecham,
                          yValueMapper: (SalesPedidosEntity data, _) =>
                              data.gtotal,
                          name:
                              'Pedidos \ntotal: ${currencyFormat.format(totalPedidos)}',
                          color: Colors.blue,
                        ),
                        ColumnSeries<SalesTicketsEntity, String>(
                          dataSource: alignedTickets,
                          xValueMapper: (SalesTicketsEntity data, _) =>
                              data.fecham,
                          yValueMapper: (SalesTicketsEntity data, _) =>
                              data.gtotal,
                          name:
                              'Tickets \ntotal: ${currencyFormat.format(totalTickets)}',
                          color: Colors.green,
                        )
                      ],
                      annotations: <CartesianChartAnnotation>[
                        // Añadiendo anotaciones por cada fecha
                        for (var entry in sumasPorFecha.entries)
                          CartesianChartAnnotation(
                              widget: Text(
                                currencyFormat.format(entry.value),
                                style: const TextStyle(fontSize: 12),
                              ),
                              coordinateUnit: CoordinateUnit.point,
                              x: entry.key, // La fecha
                              y: sumasPorFecha[entry.key],
                              verticalAlignment: ChartAlignment
                                  .near // Asegúrate de colocar la anotación debajo de las barras
                              ),
                      ],
                    ),
                  ),
                );
              } else if (state is ReportesError) {
                return Center(child: Text(state.message));
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }
}
