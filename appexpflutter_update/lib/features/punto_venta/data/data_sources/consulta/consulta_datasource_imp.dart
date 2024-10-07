import 'package:api_client/dio_client.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/consulta/consulta_datasource.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/tickets_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConsultaDatasourceImp implements ConsultaDatasource {
  final DioClient _dioClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  ConsultaDatasourceImp({required DioClient dioClient})
      : _dioClient = dioClient;
  @override
  Future<List<TicketsModel>> getSalesTickets(
      String fechaInicio, String fechaFin) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post('/getSalesTickets_n',
          queryParameters: {
            "fechaini": fechaInicio,
            "fechafin": fechaFin,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      List<dynamic> jsonList = result.data;
      final salesPedidos = jsonList
          .map((salesPedidos) => TicketsModel.fromJson(salesPedidos))
          .toList();
      return salesPedidos;
    } catch (_) {
      rethrow;
    }
  }
}
