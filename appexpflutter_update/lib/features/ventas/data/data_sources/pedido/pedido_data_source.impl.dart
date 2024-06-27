import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/ventas/data/models/pedido_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PedidoDataSourceImpl implements PedidoDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  PedidoDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<String> addDetallePedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/insertDetallePedido',
        queryParameters: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return result.data['success'] as String;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<PedidoModel> addPedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/insertPedido',
        queryParameters: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final pedido = PedidoModel.fromJson(result.data);
      return pedido;
    } catch (_) {
      rethrow;
    }
  }
}
