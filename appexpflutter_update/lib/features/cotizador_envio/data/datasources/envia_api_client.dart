import 'dart:io';
import 'package:api_client/constants/environment.dart';
import 'package:dio/dio.dart';

class EnviaApiClient {
  late final Dio _dio;

  EnviaApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.envia.com',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Environment.enviaToken}',
      },
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      responseType: ResponseType.json,
    ));
    print('DEBUG TOKEN ENVIADO: [Bearer ${Environment.enviaToken}]');
  }

  Future<Response<dynamic>> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException {
      rethrow;
    }
  }
}
