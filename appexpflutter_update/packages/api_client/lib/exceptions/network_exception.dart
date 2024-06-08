import 'dart:io';
import 'package:dio/dio.dart';
import 'package:api_client/exceptions/network_error_model.dart';
import 'package:equatable/equatable.dart';

///
/// Esta clase extiende [Equatable] e implementa [Exception].
/// Contiene una propiedad [message] y [statusCode].
/// La propiedad [message] contiene el mensaje de error y el [statusCode]
/// propiedad contiene el código de estado HTTP de la respuesta.
///
/// Esta clase tiene un constructor [fromDioError] que toma una [DioException]
/// como parámetro y establece las propiedades [statusCode] y [message] según
/// el tipo de [DioException].
///
/// Esta clase también anula el captador [props] de [Equatable] para comparar
/// instancias de esta clase basadas en las propiedades [message] y [statusCode].
///
/// Ejemplo de uso:
/// ```dart
/// try {
///   // some network request
/// } on DioException catch (e) {
///   throw NetworkException.fromDioError(e);
/// }
/// ```
class NetworkException extends Equatable implements Exception {
  late final String message;
  late final int? statusCode;
  NetworkException.fromDioError(DioException dioException) {
    statusCode = dioException.response?.statusCode;

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
          break;
        } else {
          message = 'Ocurrió un error inesperado';
          break;
        }

      case DioExceptionType.badCertificate:
        message = 'Certificado incorrecto';
        break;

      case DioExceptionType.badResponse:
        final model = NetworkErrorModel.fromJson(
            dioException.response?.data as Map<String, dynamic>);
        message = model.statusMessage ?? 'Mala respuesta inesperada';
        break;

      case DioExceptionType.unknown:
        message = 'Ocurrió un error inesperado';
        break;
    }
  }
  @override
  List<Object?> get props => [message, statusCode];
}
