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
  Future<String> addDetallePedido(List<Map<String, dynamic>> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      for (var detalle in data) {
        await _dioClient.post(
          '/insertDetallePedido',
          queryParameters: detalle,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
      return 'Detalles del pedido agregados con éxito';
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> addIdPedido(int idPedido) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/rtoPedido',
        queryParameters: {'id_pedido': idPedido},
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

  @override
  Future<String> addSesionDetallePedido(List<Map<String, dynamic>> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      for (var detalle in data) {// Agrega este log para depuración
        await _dioClient.post(
          '/insertDetalleSesion',
          queryParameters: detalle,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
      return 'Detalles del pedido agregados con éxito';
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<PedidoModel> addSesionPedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/insertSesion',
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
