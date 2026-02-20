import 'dart:io';
import 'package:api_client/exceptions/network_error_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class NetworkException extends Equatable implements Exception {
  String message = '';
  int? statusCode;

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
          message = 'Ocurrió un error inesperado (Connection): ${dioException.error}';
        }
        break;

      case DioExceptionType.badCertificate:
        message = 'Certificado incorrecto';
        break;

      case DioExceptionType.badResponse:
        final data = dioException.response?.data;
        statusCode = dioException.response?.statusCode;

        String? parsedMessage;

        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail') && data['detail'] != null) {
            parsedMessage = data['detail'].toString();
          } else if (data.containsKey('message') && data['message'] != null) {
            parsedMessage = data['message'].toString();
          } else if (data.containsKey('error') && data['error'] != null) {
            parsedMessage = data['error'].toString();
          } else if (data.containsKey('status_message') &&
              data['status_message'] != null) {
            parsedMessage = data['status_message'].toString();
          } else if (data.containsKey('errors')) {
            // Handle validation errors often returned as a map or list
            final errors = data['errors'];
            if (errors is Map) {
              // Join all error messages
              parsedMessage = errors.values.join('\n');
            } else if (errors is List) {
              parsedMessage = errors.join('\n');
            } else {
              parsedMessage = errors.toString();
            }
          }
        } else if (data is String) {
          parsedMessage = data;
        }

        if (statusCode == 404) {
          message = parsedMessage ??
              'No se encontraron elementos que coincidan con la búsqueda';
        } else if (statusCode == 500) {
          message =
              'Error del servidor. ${parsedMessage ?? "Por favor, inténtelo de nuevo más tarde."}';
        } else if (statusCode == 400 || statusCode == 422) {
          message =
              parsedMessage ?? 'Error en la solicitud. Verifique los datos.';
        } else if (statusCode == 403) {
          message = parsedMessage ?? 'No tiene permisos para realizar esta acción.';
        } else {
          message = parsedMessage ??
              'Error inesperado: ${dioException.response?.statusMessage ?? 'Código $statusCode'}';
        }
        break;

      case DioExceptionType.unknown:
        message = 'Ocurrió un error inesperado (Unknown): ${dioException.message}';
        break;
    }

    // Para manejar los casos donde statusCode no se haya inicializado
    statusCode ??= dioException.response?.statusCode;
  }

  @override
  List<Object?> get props => [message, statusCode];
}