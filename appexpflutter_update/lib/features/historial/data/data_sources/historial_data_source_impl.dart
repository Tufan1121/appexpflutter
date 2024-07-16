import 'package:api_client/api_client.dart';
import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source.dart';
import 'package:appexpflutter_update/features/historial/data/models/detalle_sesion_model.dart';
import 'package:appexpflutter_update/features/historial/data/models/historial_cotiza_model.dart';
import 'package:appexpflutter_update/features/historial/data/models/historial_pedido_model.dart';
import 'package:appexpflutter_update/features/historial/data/models/historial_sesion_model.dart';
import 'package:appexpflutter_update/features/precios/data/models/producto_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistorialDataSourceImpl implements HistorialDataSource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  HistorialDataSourceImpl({required DioClient dioclient})
      : _dioClient = dioclient;
  @override
  Future<List<HistorialPedidoModel>> getHistorialPedido(
      String parameter) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/buscaclientepedido/',
          queryParameters: {
            'parametro': parameter,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      List<dynamic> jsonList = result.data;
      final historial =
          jsonList.map((e) => HistorialPedidoModel.fromJson(e)).toList();
      return historial;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<HistorialCotizaModel>> getHistorialCotiza(
      String parameter) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/buscaclientecotiza/',
          queryParameters: {
            'parametro': parameter,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      List<dynamic> jsonList = result.data;
      final historial =
          jsonList.map((e) => HistorialCotizaModel.fromJson(e)).toList();
      return historial;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<HistorialSesionModel>> getHistorialSesion(
      String parameter) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/buscaclientesesion/',
          queryParameters: {
            'parametro': parameter,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      List<dynamic> jsonList = result.data;
      final historial =
          jsonList.map((e) => HistorialSesionModel.fromJson(e)).toList();
      return historial;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<DetalleSesionModel>> getHistorialDetalleSesion(
      String idSesion) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/selectfromsesiond/',
          queryParameters: {
            'id_sesion': idSesion,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      List<dynamic> jsonList = result.data;
      final detalleSesion =
          jsonList.map((e) => DetalleSesionModel.fromJson(e)).toList();
      return detalleSesion;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ProductoModel> getProductInfo(String productKey) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/productScan/',
          queryParameters: {'producto': productKey},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      if (jsonList.isNotEmpty) {
        final producto = ProductoModel.fromJson(jsonList[0]);
        return producto;
      } else {
        throw NotFoundException('Producto no encontrado');
      }
    } catch (_) {
      rethrow;
    }
  }

}
