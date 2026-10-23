library api_client;

import 'dart:io';
import 'package:api_client/constants/environment.dart';
import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:dio/dio.dart';


class DioClient {
  late final Dio _dio;

  /// Callback global que la app configura para manejar un 401 (token caducado
  /// o inválido): típicamente borra el token local y redirige al login.
  /// Se invoca para cualquier 401 EXCEPTO el del propio login (`/token`), que
  /// debe seguir mostrando el mensaje de credenciales inválidas en pantalla.
  /// [message] trae el `detail` del backend (p.ej. "Sesión iniciada en otro
  /// dispositivo") para poder avisarlo antes de redirigir al login.
  static void Function(String? message)? onUnauthorized;

  DioClient() {
    _dio = Dio();
    _dio
      ..options.baseUrl = Environment.activeApiUrl
      ..options.headers = {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      }
      ..options.connectTimeout = const Duration(milliseconds: 10000)
      ..options.receiveTimeout = const Duration(milliseconds: 15000)
      ..options.responseType = ResponseType.json
      ..interceptors.add(InterceptorsWrapper(
        onError: (error, handler) {
          // El login (/token) y el cierre de sesión (/logout) se excluyen: el
          // primero debe mostrar el error de credenciales en pantalla y el
          // segundo ya está cerrando sesión (evita recursión en el redirect).
          final path = error.requestOptions.path;
          final isAuthRequest =
              path.contains('/token') || path.contains('/logout');
          if (error.response?.statusCode == 401 && !isAuthRequest) {
            String? detail;
            final data = error.response?.data;
            if (data is Map && data['detail'] is String) {
              detail = data['detail'] as String;
            }
            onUnauthorized?.call(detail);
          }
          return handler.next(error);
        },
      ))
      ..interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        logPrint: (obj) => print('>>> DIO: $obj'),
      ));
  }

  /// ¿Conviene reintentar con la otra URL? Sí cuando:
  /// - Hay un error de CONEXIÓN (túnel/fibra caída, timeouts, socket).
  /// - El gateway respondió pero el backend detrás está caído: 502 Bad Gateway,
  ///   503 Service Unavailable, 504 Gateway Timeout (típico de nginx cuando el
  ///   upstream/túnel no responde).
  /// NO salta ante errores de aplicación (400/401/404/500), porque ahí el
  /// backend sí está vivo y respondiendo.
  ///
  /// Con [idempotente] en false (POST/PUT/PATCH/DELETE) solo salta cuando la
  /// petición seguro NO llegó al backend (no conectó, o 502/503). Si se envió y
  /// tardó en responder (send/receiveTimeout, 504) el backend pudo haberla
  /// procesado: repetirla en la otra URL guardaba dos veces la misma venta.
  bool _shouldFailover(DioException e, {bool idempotente = true}) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return true;
    }
    if (idempotente &&
        (e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.error is SocketException)) {
      return true;
    }
    if (e.type == DioExceptionType.badResponse) {
      final code = e.response?.statusCode ?? 0;
      return code == 502 || code == 503 || (idempotente && code == 504);
    }
    return false;
  }

  /// Tiempo de espera de las peticiones que guardan (POST/PUT/PATCH/DELETE):
  /// el backend puede tardar (p.ej. arma el PDF del pedido) y cortar antes
  /// hacía que el usuario reintentara algo que sí se estaba guardando.
  static const Duration _receiveTimeoutEscritura = Duration(seconds: 60);

  Options _opcionesEscritura(Options? options) =>
      (options ?? Options()).copyWith(
        receiveTimeout: options?.receiveTimeout ?? _receiveTimeoutEscritura,
      );

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() requestFunction, {
    bool idempotente = true,
  }) async {
    final urls = Environment.apiUrls;
    final start = Environment.activeIndex;
    DioException? lastError;

    // Intenta con la URL activa; ante un error de conexión, prueba la siguiente
    // (failover). Si responde el servidor (4xx/5xx) NO cambia de URL.
    for (var i = 0; i < urls.length; i++) {
      final idx = (start + i) % urls.length;
      _dio.options.baseUrl = urls[idx];
      try {
        final response = await requestFunction();
        Environment.activeIndex = idx; // recuerda la URL que sí respondió
        return response;
      } on DioException catch (e) {
        lastError = e;
        final hayOtra = i < urls.length - 1;
        if (_shouldFailover(e, idempotente: idempotente) && hayOtra) {
          continue; // la URL no respondió (o gateway caído): prueba el respaldo
        }
        rethrow;
      }
    }
    throw lastError!;
  }

  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(() => _dio.get(
          url,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        ));
  }

  Future<Response<dynamic>> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
        () => _dio.post(
              uri,
              data: data,
              queryParameters: queryParameters,
              options: _opcionesEscritura(options),
              cancelToken: cancelToken,
              onSendProgress: onSendProgress,
              onReceiveProgress: onReceiveProgress,
            ),
        idempotente: false);
  }

  Future<Response<dynamic>> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
        () => _dio.put(
              uri,
              data: data,
              queryParameters: queryParameters,
              options: _opcionesEscritura(options),
              cancelToken: cancelToken,
              onSendProgress: onSendProgress,
              onReceiveProgress: onReceiveProgress,
            ),
        idempotente: false);
  }

  Future<Response<dynamic>> patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
        () => _dio.patch(
              uri,
              data: data,
              queryParameters: queryParameters,
              options: _opcionesEscritura(options),
              cancelToken: cancelToken,
              onSendProgress: onSendProgress,
              onReceiveProgress: onReceiveProgress,
            ),
        idempotente: false);
  }

  Future<Response<dynamic>> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _request(
        () => _dio.delete(
              uri,
              data: data,
              queryParameters: queryParameters,
              options: _opcionesEscritura(options),
              cancelToken: cancelToken,
            ),
        idempotente: false);
  }
}
