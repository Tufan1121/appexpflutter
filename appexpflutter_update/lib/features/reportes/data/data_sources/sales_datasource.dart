import 'package:appexpflutter_update/features/reportes/data/models/sales_pedidos_model.dart';
import 'package:appexpflutter_update/features/reportes/data/models/sales_tickets_model.dart';

abstract interface class SalesDatasource {
  Future<List<SalesPedidosModel>> getSalesPedidos();
  Future<List<SalesTicketsModel>> getSalesTickets();
}
