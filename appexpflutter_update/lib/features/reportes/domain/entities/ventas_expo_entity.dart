import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';
import 'package:equatable/equatable.dart';

/// Resumen de ventas de la expo activa, mismo origen que la pestaña Ventas de
/// la lista de pedidos web (GET /ventasExpo/).
class VentasExpoEntity extends Equatable {
  final MetaExpoEntity meta;
  final List<SalesPedidosEntity> pedidosPorDia;
  final List<SalesTicketsEntity> ticketsPorDia;
  final List<SalesVendedorEntity> porVendedor;

  const VentasExpoEntity({
    required this.meta,
    required this.pedidosPorDia,
    required this.ticketsPorDia,
    required this.porVendedor,
  });

  @override
  List<Object?> get props => [meta, pedidosPorDia, ticketsPorDia, porVendedor];
}
