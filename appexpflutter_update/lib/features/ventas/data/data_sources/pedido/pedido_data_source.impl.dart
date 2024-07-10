import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/config/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/ventas/data/models/cotiza_model.dart';
import 'package:appexpflutter_update/features/ventas/data/models/pedido_model.dart';
import 'package:appexpflutter_update/features/ventas/data/models/sesion_model.dart';
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
      for (var detalle in data) {
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
      return 'La sesión de pedido fue agregada con éxito';
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<SesionModel> addSesionPedido(Map<String, dynamic> data) async {
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

      if (result.data == null || result.data is! Map<String, dynamic>) {
        throw NotFoundException('Respuesta inválida del servidor');
      }

      final responseData = result.data as Map<String, dynamic>;

      if (responseData.containsKey('error')) {
        throw NotFoundException(
            'Error en la respuesta del servidor: ${responseData['error']}');
      }

      final pedido = SesionModel.fromJson(responseData);
      return pedido;
    } catch (e) {
      if (e is DioException) {
        // Manejo específico de errores de Dio
        if (e.response != null && e.response!.statusCode == 200) {
          final responseData = json.decode(e.response!.data);
          if (responseData['error'] != null) {
            throw NotFoundException(
                'Error en la respuesta del servidor: ${responseData['error']}');
          }
        }
      }
      rethrow;
    }
  }

  @override
  Future<String> addCotizaDetallePedido(List<Map<String, dynamic>> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      for (var detalle in data) {
        await _dioClient.post(
          '/insertDetalleCotiza',
          queryParameters: detalle,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
      return 'La cotización de pedido fue agregada con éxito';
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<CotizaModel> addCotizaPedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/insertCotiza',
        queryParameters: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final pedido = CotizaModel.fromJson(result.data);
      return pedido;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> addIdCotizaPedido(int idCotiza) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/rtoCotiza',
        queryParameters: {'id_cotiza': idCotiza},
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
}
