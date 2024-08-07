import 'package:api_client/dio_client.dart';
import 'package:appexpflutter_update/features/reportes/data/data_sources/sales_datasource.dart';
import 'package:appexpflutter_update/features/reportes/data/models/sales_pedidos_model.dart';
import 'package:appexpflutter_update/features/reportes/data/models/sales_tickets_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SalesDatasourceImp implements SalesDatasource {
  final DioClient _dioClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  SalesDatasourceImp({required DioClient dioClient}) : _dioClient = dioClient;
  @override
  Future<List<SalesPedidosModel>> getSalesPedidos() async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post('/getSalesPedidos',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      List<dynamic> jsonList = result.data;
      final salesPedidos = jsonList.map( (salesPedidos) => SalesPedidosModel.fromJson(salesPedidos)).toList();
      return salesPedidos;
    } catch (_) {
      rethrow;
    }
  }
  
  @override
  Future<List<SalesTicketsModel>> getSalesTickets() async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post('/getSalesTickets',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      List<dynamic> jsonList = result.data;
      final salesTickets = jsonList.map( (salesPedidos) => SalesTicketsModel.fromJson(salesPedidos)).toList();
      return salesTickets;
    } catch (_) {
      rethrow;
    }
  }
}
