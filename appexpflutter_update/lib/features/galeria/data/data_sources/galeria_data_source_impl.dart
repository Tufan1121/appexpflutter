
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:api_client/api_client.dart';
import 'package:galeria/data/data_sources/galeria_data_source.dart';
import 'package:galeria/data/model/galeria_model.dart';
import 'package:galeria/data/model/medidas_model.dart';
import 'package:galeria/data/model/producto_inv_model.dart';
import 'package:galeria/data/model/producto_model.dart';
import 'package:galeria/data/model/tabla_precio_model.dart';

class GaleriaDataSourceImpl implements GaleriaDataSource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  GaleriaDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<ProductoInvModel>> getgalinventario(
      String descripcion, String diseno) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post('/getgalinventario',
          queryParameters: {
            'descripcio': descripcion,
            'diseno': diseno,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      final productosInventario = jsonList
          .map(
            (json) => ProductoInvModel.fromJson(json),
          )
          .toList();
      return productosInventario;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<GaleriaModel>> getgallery(
      {String? descripcion, int? regg}) async {
    final token = await storage.read(key: 'accessToken');

    final queryParameters = <String, dynamic>{};
    if (regg != null && descripcion!.isEmpty) {
      queryParameters['regg'] = regg;
    } else if (descripcion!.isNotEmpty && regg == null) {
      queryParameters['descripcio'] = descripcion;
    } else if (descripcion.isNotEmpty && regg != null) {
      queryParameters['descripcio'] = descripcion;
      queryParameters['regg'] = regg;
    }

    try {
      final result = await _dioClient.post('/getgallery',
          queryParameters: queryParameters,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      final galeria = jsonList
          .map(
            (json) => GaleriaModel.fromJson(json),
          )
          .toList();
      return galeria;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<ProductoModel>> getgallerypics(String descripcion) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post('/getgallerypics',
          queryParameters: {
            'descripcio': descripcion,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      final producto = jsonList
          .map(
            (json) => ProductoModel.fromJson(json),
          )
          .toList();
      return producto;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<MedidasModel>> getgalmedidas(
      String descripcion, String diseno) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post('/getgalmedidas',
          queryParameters: {
            'descripcio': descripcion,
            'diseno': diseno,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      final medidas = jsonList
          .map(
            (json) => MedidasModel.fromJson(json),
          )
          .toList();
      return medidas;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<TablaPrecioModel>> getTablaPrecio(
      String descripcion, String diseno) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post('/gettablaprecios',
          queryParameters: {
            'descripcio': descripcion,
            'diseno': diseno,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      final tabla = jsonList
          .map(
            (json) => TablaPrecioModel.fromJson(json),
          )
          .toList();
      return tabla;
    } catch (_) {
      rethrow;
    }
  }
}
