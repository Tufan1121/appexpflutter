import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventarios/data/data_sources/inventario_expo_data_source.dart';
import 'package:inventarios/data/models/medidas_model.dart';
import 'package:inventarios/data/models/producto_expo_model.dart';

class InventarioExpoDataSourceImpl implements InventarioExpoDataSource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  InventarioExpoDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<ProductoExpoModel>> getProductoExpo(
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
  Future<List<ProductoExpoModel>> getProductoGlobal(
      Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/busquedaGlobal/',
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
  Future<List<MedidasModelInv>> getMedidas() async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get(
        '/getmedidas',
        options: Options(
          headers: { 'Authorization': 'Bearer $token' },
        ),
      );
      final List<dynamic> jsonList = result.data;
      final medidas = parseMedidas(jsonList);
      return medidas;
    } catch (_) {
      rethrow;
    }
  }
}
