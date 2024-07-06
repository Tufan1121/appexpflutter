import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source.dart';
import 'package:appexpflutter_update/features/historial/data/models/historial_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistorialDataSourceImpl implements HistorialDataSource {
  final DioClient _dioclient;
  final storage = const FlutterSecureStorage();

  HistorialDataSourceImpl({required DioClient dioclient})
      : _dioclient = dioclient;
  @override
  Future<List<HistorialModel>> getHistorial(
      String parameter, String endpoint) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioclient.get(endpoint,
          queryParameters: {
            'parametro': parameter,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      List<dynamic> jsonList = result.data;
      final historial =
          jsonList.map((e) => HistorialModel.fromJson(e)).toList();
      return historial;
    } catch (_) {
      rethrow;
    }
  }
}
