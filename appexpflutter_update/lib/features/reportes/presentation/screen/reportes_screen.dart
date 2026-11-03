import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/reportes/presentation/bloc/reportes_bloc.dart';
import 'package:appexpflutter_update/features/reportes/presentation/screen/widgets/meta_avance_card.dart';
import 'package:appexpflutter_update/features/reportes/presentation/screen/widgets/ventas_barras_chart.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:appexpflutter_update/features/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ReportesScreen extends HookWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);

    // Toda la expo activa, igual que la lista de pedidos web (sin rango de
    // fechas): /ventasExpo/ trae meta, venta por día y por vendedor.
    void actualizar() => context.read<ReportesBloc>().add(GetVentasExpoEvent());

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
                        const Expanded(
                          child: Text(
                            'Ventas de la expo activa',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: actualizar,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Actualizar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colores.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<ReportesBloc, ReportesState>(
                  builder: (context, state) {
                    if (state is ReportesLoading) {
                      return const Center(child: LoadingIndicator());
                    } else if (state is ReportesError) {
                      return Center(child: Text(state.message));
                    } else if (state is! ReportesLoaded) {
                      return Container();
                    }

                    // ===== Por día: pedidos + tickets alineados por fecha =====
                    final Map<String, double> pedPorFecha = {};
                    final Map<String, double> tikPorFecha = {};
                    for (final p in state.salesPedidos) {
                      pedPorFecha[p.fecham] =
                          (pedPorFecha[p.fecham] ?? 0) + p.gtotal;
                    }
                    for (final t in state.salesTickets) {
                      tikPorFecha[t.fecham] =
                          (tikPorFecha[t.fecham] ?? 0) + t.gtotal;
                    }
                    final fechas = {...pedPorFecha.keys, ...tikPorFecha.keys}
                        .toList()
                      ..sort();
                    final dias = [
                      for (final f in fechas)
                        BarraVenta(f, pedPorFecha[f] ?? 0, tikPorFecha[f] ?? 0),
                    ].where((b) => b.total > 0).toList();

                    // fecham viene como yyyy-MM-dd
                    String fechaCorta(BarraVenta b) {
                      final p = b.etiqueta.split('-');
                      return p.length == 3 ? '${p[2]}/${p[1]}' : b.etiqueta;
                    }

                    String fechaLarga(BarraVenta b) {
                      final p = b.etiqueta.split('-');
                      return p.length == 3
                          ? '${p[2]}/${p[1]}/${p[0]}'
                          : b.etiqueta;
                    }

                    // ===== Por vendedor: ranking de mayor a menor =====
                    final vendedores = [
                      for (final v in state.salesVendedor)
                        BarraVenta(v.vendedor, v.pedidos, v.puntoventa),
                    ].where((b) => b.total > 0).toList()
                      ..sort((a, b) => b.total.compareTo(a.total));

                    final metaExpo = state.metaExpo;

                    return Column(
                      children: [
                        if (metaExpo != null) MetaAvanceCard(meta: metaExpo),
                        // Selector con fondo propio (como las pestañas de la
                        // web) para que se lea sobre la curva blanca del fondo
                        Container(
                          height: 44,
                          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kColorBorde),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: kColorPedidos,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            dividerColor: Colors.transparent,
                            labelColor: Colors.white,
                            unselectedLabelColor: kColorTextoTenue,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                            tabs: const [
                              Tab(text: 'Por día'),
                              Tab(text: 'Por vendedor'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              SingleChildScrollView(
                                child: VentasBarrasCard(
                                  icono: Icons.calendar_month_outlined,
                                  titulo: 'Venta por día',
                                  subtitulo:
                                      'Pedidos y tickets cobrados por día de la '
                                      'expo. El pedido que ya se convirtió en '
                                      'ticket cuenta solo como ticket.',
                                  barras: dias,
                                  etiquetaEje: fechaCorta,
                                  tituloDetalle: fechaLarga,
                                ),
                              ),
                              SingleChildScrollView(
                                child: VentasBarrasCard(
                                  icono: Icons.people_outline,
                                  titulo: 'Desempeño por vendedor',
                                  subtitulo:
                                      'Comparativo de ventas y participación '
                                      'de cada vendedor.',
                                  barras: vendedores,
                                  ranking: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
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
