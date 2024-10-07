import 'package:api_client/api_client.dart';
import 'package:punto_venta/data/data_sources/pedido/pedido_data_source.dart';
import 'package:punto_venta/data/models/pedido_model.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PedidoDataVentaSourceImpl implements PedidoDataVentaSource {
  final DioClient _dioClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  PedidoDataVentaSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<PedidoModel> addPedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/insertprePos',
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
  Future<String> addDetallePedido(List<Map<String, dynamic>> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      for (var detalle in data) {
        await _dioClient.post(
          '/insertPosed',
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
}
