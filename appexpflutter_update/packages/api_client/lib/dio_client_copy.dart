library api_client;

import 'dart:io';
import 'package:api_client/constants/environment.dart';
import 'package:dio/dio.dart';

class DioClient {
  late final Dio _dio; // Declaración tardía de una instancia de Dio.

  DioClient() {
    _dio = Dio(); // Inicializa la instancia de Dio.
    _dio
          ..options.baseUrl = Environment
              .apiUrl // Establece la URL base para todas las solicitudes.
          ..options.headers = {
            HttpHeaders.contentTypeHeader: ContentType
                .json.mimeType, // Establece el tipo de contenido como JSON.
          }
          ..options.connectTimeout = const Duration(
              milliseconds: 15000) // Establece el tiempo máximo de conexión.
          ..options.receiveTimeout = const Duration(
              milliseconds:
                  15000) // Establece el tiempo máximo de recepción de datos.
          ..options.responseType =
              ResponseType.json // Establece el tipo de respuesta esperado.
        ;
  }

  /// Método GET para realizar solicitudes HTTP GET.
  Future<Response<dynamic>> get(
    String url, {
    // URL de la solicitud (relativa a la base URL).
    Map<String, dynamic>? queryParameters, // Parámetros de consulta opcionales.
    Options? options, // Opciones adicionales para la solicitud.
    CancelToken? cancelToken, // Token para cancelar la solicitud.
    ProgressCallback?
        onReceiveProgress, // Callback para el progreso de recepción de datos.
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow; // Relanza la excepción para ser manejada en otro lugar.
    }
  }

  /// Método POST para realizar solicitudes HTTP POST.
  Future<Response<dynamic>> post(
    String uri, {
    dynamic data, // Datos opcionales para enviar en la solicitud.
    Map<String, dynamic>? queryParameters, 
    Options? options, 
    CancelToken? cancelToken, 
    ProgressCallback?
        onSendProgress, // Callback para el progreso de envío de datos.
    ProgressCallback?
        onReceiveProgress, 
  }) async {
    try {
      final response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow; 
    }
  }

  /// Método PUT para realizar solicitudes HTTP PUT.
  Future<Response<dynamic>> put(
    String uri, {
    dynamic data, 
    Map<String, dynamic>? queryParameters,
    Options? options, 
    CancelToken? cancelToken, 
    ProgressCallback?
        onSendProgress, 
    ProgressCallback?
        onReceiveProgress, 
  }) async {
    try {
      final response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow; 
    }
  }

  /// Método PATCH para realizar solicitudes HTTP PATCH.
  Future<Response<dynamic>> patch(
    String uri, {
    dynamic data, 
    Map<String, dynamic>? queryParameters, 
    Options? options, 
    CancelToken? cancelToken, 
    ProgressCallback?
        onSendProgress, 
    ProgressCallback?
        onReceiveProgress, 
  }) async {
    try {
      final response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow; 
    }
  }

  /// Método DELETE para realizar solicitudes HTTP DELETE.
  Future<Response<dynamic>> delete(
    String uri, {
    dynamic data, 
    Map<String, dynamic>? queryParameters, 
    Options? options, 
    CancelToken? cancelToken, 
  }) async {
    try {
      final response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow; 
    }
  }
}