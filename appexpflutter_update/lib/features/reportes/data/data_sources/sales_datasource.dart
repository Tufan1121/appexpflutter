import 'package:appexpflutter_update/features/reportes/data/models/sales_pedidos_model.dart';
import 'package:appexpflutter_update/features/reportes/data/models/sales_tickets_model.dart';
import 'package:appexpflutter_update/features/reportes/data/models/sales_vendedor_model.dart';
import 'package:appexpflutter_update/features/reportes/data/models/meta_expo_model.dart';

abstract interface class SalesDatasource {
  Future<List<SalesPedidosModel>> getSalesPedidos({String? fechaini, String? fechafin});
  Future<List<SalesTicketsModel>> getSalesTickets({String? fechaini, String? fechafin});
  Future<List<SalesVendedorModel>> getSalesByVendedor({String? fechaini, String? fechafin});
  Future<MetaExpoModel> getMetaExpo();
}
