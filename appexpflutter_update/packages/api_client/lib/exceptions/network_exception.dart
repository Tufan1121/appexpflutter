import 'dart:io';

import 'package:api_client/exceptions/network_error_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class NetworkException extends Equatable implements Exception {
  late final String message;
  late final int? statusCode;

  NetworkException.customMessage(String messages) {
    message = messages;
  }

  NetworkException.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = 'La solicitud al servidor API fue cancelada';
        break;

      case DioExceptionType.connectionTimeout:
        message = 'Tiempo de espera de conexión con el servidor API';
        break;

      case DioExceptionType.receiveTimeout:
        message = 'Recibir tiempo de espera en conexión con el servidor API';
        break;

      case DioExceptionType.sendTimeout:
        message = 'Enviar tiempo de espera en conexión con el servidor API';
        break;

      case DioExceptionType.connectionError:
        if (dioException.error.runtimeType == SocketException) {
          message = 'Por favor revise su conexion a internet';
        } else {
          message = 'Ocurrió un error inesperado';
        }
        break;

      case DioExceptionType.badCertificate:
        message = 'Certificado incorrecto';
        break;

      case DioExceptionType.badResponse:
        final data = dioException.response?.data;
        statusCode = dioException.response?.statusCode;

        if (statusCode == 404) {
          if (data is Map<String, dynamic> && data.containsKey('detail')) {
            message = data['detail'];
          } else {
            message =
                'No se encontraron elementos que coincidan con la búsqueda';
          }
        } else {
          if (data is Map<String, dynamic>) {
            final model = NetworkErrorModel.fromJson(data);
            message = model.statusMessage ?? 'Credenciales incorrectas';
          } else {
            message =
                'Error inesperado: ${dioException.response?.statusMessage ?? 'error desconocido'}';
          }
        }
        break;

      case DioExceptionType.unknown:
        message = 'Ocurrió un error inesperado';
        break;
    }

    // Para manejar los casos donde statusCode no se haya inicializado
    statusCode ??= dioException.response?.statusCode;
  }

  @override
  List<Object?> get props => [message, statusCode];
}
