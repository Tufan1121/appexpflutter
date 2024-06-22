import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/config/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/precios/data/models/producto_model.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/producto_venta_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductoVentaDataSourceImpl implements ProductoVentaDataSource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  ProductoVentaDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

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

  @override
  Future<List<ProductoModel>> getIBodegaProducts(
      Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/ibodegas/',
          queryParameters: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      final productosBodega = jsonList
          .map(
            (json) => ProductoModel.fromJson(json),
          )
          .toList();
      return productosBodega;
      // if (jsonList.isNotEmpty) {
      //   final productosRelativos = jsonList
      //       .map(
      //         (json) => ProductoModel.fromJson(json),
      //       )
      //       .toList();
      //   return productosRelativos;
      // } else {
      //   throw NotFoundException('Productos no encontrados');
      // }
    } catch (_) {
      rethrow;
    }
  }
}
