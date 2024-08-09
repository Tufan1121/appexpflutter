import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/presentation/bloc/reportes_bloc.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
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
        child: AppBar(
          leading: IconButton(
            onPressed: () => HomeRoute().push(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colores.secondaryColor.withOpacity(0.78),
          title: Text(
            'REPORTES',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colores.scaffoldBackgroundColor,
              shadows: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2.0, 5.0),
                )
              ],
            ),
          ),
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
                        maximum: 400000,
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
                          dataSource: listaPedidos,
                          xValueMapper: (SalesPedidosEntity data, _) =>
                              data.fecham,
                          yValueMapper: (SalesPedidosEntity data, _) =>
                              data.gtotal,
                          name:
                              'Pedidos \ntotal: ${currencyFormat.format(totalPedidos)}',
                          color: Colors.blue,
                        ),
                        ColumnSeries<SalesTicketsEntity, String>(
                          dataSource: listaTickets,
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
