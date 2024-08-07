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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
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
                final NumberFormat currencyFormat = NumberFormat.currency(
                  locale: 'en_US',
                  symbol: '\$',
                  decimalDigits: 0,
                );

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(
                        
                      ),
                      title: const ChartTitle(
                          text: 'Sales Pedidos y Tickets',
                          textStyle: TextStyle(color: Colores.secondaryColor)),
                      legend: const Legend(isVisible: true),
                      onTooltipRender: (TooltipArgs args) {
                        args.text =
                            '${args.dataPoints![args.pointIndex!.toInt()].x} : ${currencyFormat.format(args.dataPoints![args.pointIndex!.toInt()].y)}';
                      },
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: [
                        ColumnSeries<SalesPedidosEntity, String>(
                          dataSource: listaPedidos,
                          xValueMapper: (SalesPedidosEntity data, _) =>
                              data.fecham,
                          yValueMapper: (SalesPedidosEntity data, _) =>
                              data.gtotal,
                          name: 'Pedidos',
                          color: Colors.blue,
                          dataLabelMapper: (SalesPedidosEntity data, _) =>
                              currencyFormat.format(data.gtotal),
                        ),
                        ColumnSeries<SalesTicketsEntity, String>(
                          dataSource: listaTickets,
                          xValueMapper: (SalesTicketsEntity data, _) =>
                              data.fecham,
                          yValueMapper: (SalesTicketsEntity data, _) =>
                              data.gtotal,
                          name: 'Tickets',
                          color: Colors.green,
                        )
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
