import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/inventario_expo/inventario_expo_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/producto_expo_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InventarioExpoVentaDataSourceImpl
    implements InventarioExpoVentaDataSource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  InventarioExpoVentaDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<ProductoExpoModel>> getProductosExpo(
      Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/busquedaExpo/',
          queryParameters: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      final productosBodega = jsonList
          .map(
            (json) => ProductoExpoModel.fromJson(json),
          )
          .toList();
      return productosBodega;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ProductoExpoModel> getProductoExpo(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/buscaSpock/',
          queryParameters: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      if (jsonList.isNotEmpty) {
        final reducedJson = jsonList.first as Map<String, dynamic>;
        final fullJson = convertReducedJsonToFullJson(reducedJson);
        final productoExpo = ProductoExpoModel.fromJson(fullJson);
        return productoExpo;
      } else {
        throw Exception('No data found');
      }
    } catch (_) {
      rethrow;
    }
  }
}
