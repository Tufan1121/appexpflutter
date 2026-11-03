import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/ventas_expo_entity.dart';

/// Respuesta de GET /ventasExpo/:
/// { meta: {meta, alcanzado, pedidos, tickets, falta, porcentaje},
///   por_dia: [{fecha, pedidos, tickets}],
///   por_vendedor: [{vendedor, pedidos, tickets}], ... }
class VentasExpoModel extends VentasExpoEntity {
  const VentasExpoModel({
    required super.meta,
    required super.pedidosPorDia,
    required super.ticketsPorDia,
    required super.porVendedor,
  });

  static double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;

  factory VentasExpoModel.fromJson(Map<String, dynamic> json) {
    final m = (json['meta'] as Map?)?.cast<String, dynamic>() ?? {};
    final dias = (json['por_dia'] as List? ?? []).cast<Map>();
    final vends = (json['por_vendedor'] as List? ?? []).cast<Map>();
    return VentasExpoModel(
      meta: MetaExpoEntity(
        meta: _d(m['meta']),
        alcanzado: _d(m['alcanzado']),
        pedidos: _d(m['pedidos']),
        puntoventa: _d(m['tickets']),
        falta: _d(m['falta']),
        porcentaje: _d(m['porcentaje']),
      ),
      pedidosPorDia: [
        for (final d in dias)
          SalesPedidosEntity(fecham: '${d['fecha']}', gtotal: _d(d['pedidos'])),
      ],
      ticketsPorDia: [
        for (final d in dias)
          SalesTicketsEntity(fecham: '${d['fecha']}', gtotal: _d(d['tickets'])),
      ],
      porVendedor: [
        for (final v in vends)
          SalesVendedorEntity(
            vendedor: '${v['vendedor'] ?? ''}',
            pedidos: _d(v['pedidos']),
            puntoventa: _d(v['tickets']),
            gtotal: _d(v['pedidos']) + _d(v['tickets']),
          ),
      ],
    );
  }
}
