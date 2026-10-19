import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/ventas/data/models/cotiza_model.dart';
import 'package:appexpflutter_update/features/ventas/data/models/pedido_model.dart';
import 'package:appexpflutter_update/features/ventas/data/models/sesion_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PedidoDataSourceImpl implements PedidoDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  PedidoDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<String> addDetallePedido(List<Map<String, dynamic>> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      for (var detalle in data) {
        await _dioClient.post(
          '/insertDetallePedido',
          queryParameters: detalle,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
      return 'Detalles del pedido agregados con éxito';
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> addIdPedido(int idPedido) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/rtoPedido',
        queryParameters: {'id_pedido': idPedido},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return result.data['success'] as String;
    } catch (_) {
      rethrow;
    }
  }

  /// Manda el PDF del pedido al cliente por WhatsApp desde el número de expo
  /// (plantilla de Meta, backend /enviarPedidoWhatsapp). Si [telefono] viene
  /// vacío el backend usa el del cliente del pedido con su clave de país; si
  /// viene (capturado al enviar) se manda con [ladaPais] y, con [guardar], se
  /// queda en el cliente. Lanza [TelefonoClienteException] si el cliente no
  /// tiene número o es inválido, y Exception con el `detail` en otros errores.
  /// Con [cotizacion] usa /enviarCotizacionWhatsapp (mismas reglas, otra
  /// plantilla) y [pedidos] es el folio de la cotización.
  @override
  Future<String> enviarPedidoWhatsapp(
      {required String pedidos,
      int? idExpo,
      String telefono = '',
      String ladaPais = '',
      bool guardar = false,
      bool cotizacion = false}) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        cotizacion ? '/enviarCotizacionWhatsapp' : '/enviarPedidoWhatsapp',
        queryParameters: {
          'pedidos': pedidos,
          if (idExpo != null) 'id_expo': idExpo,
          if (telefono.trim().isNotEmpty) 'telefono': telefono.trim(),
          if (ladaPais.trim().isNotEmpty) 'lada_pais': ladaPais.trim(),
          if (guardar) 'guardar': 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          // Síncrono: puede generar el PDF y esperar la respuesta de Meta.
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      // Solo los últimos 4 dígitos: el vendedor no necesita ver el número
      final tel = (result.data['telefono'] ?? '').toString();
      final fin = tel.length > 4 ? tel.substring(tel.length - 4) : tel;
      return 'WhatsApp enviado al cliente (…$fin)';
    } on DioException catch (e) {
      final data = e.response?.data;
      final detail = data is Map ? data['detail'] : null;
      if (e.response?.statusCode == 400 &&
          detail is String &&
          detail.startsWith('Telefono')) {
        throw TelefonoClienteException(detail);
      }
      throw Exception(detail is String ? detail : 'No se pudo enviar el WhatsApp');
    }
  }

  @override
  Future<PedidoModel> addPedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      // Construir query string manualmente para garantizar que todos los params lleguen
      final queryString = data.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      print('>>> PEDIDO URL: /insertPedido?$queryString');
      final result = await _dioClient.post(
        '/insertPedido?$queryString',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final pedido = PedidoModel.fromJson(result.data);
      return pedido;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> addSesionDetallePedido(List<Map<String, dynamic>> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      for (var detalle in data) {
        await _dioClient.post(
          '/insertDetalleSesion',
          queryParameters: detalle,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
      return 'La sesión de pedido fue agregada con éxito';
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<SesionModel> addSesionPedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/insertSesion',
        queryParameters: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (result.data == null || result.data is! Map<String, dynamic>) {
        throw NotFoundException('Respuesta inválida del servidor');
      }

      final responseData = result.data as Map<String, dynamic>;

      if (responseData.containsKey('error')) {
        throw NotFoundException(
            'Error en la respuesta del servidor: ${responseData['error']}');
      }

      final pedido = SesionModel.fromJson(responseData);
      return pedido;
    } catch (e) {
      if (e is DioException) {
        // Manejo específico de errores de Dio
        if (e.response != null && e.response!.statusCode == 200) {
          final responseData = json.decode(e.response!.data);
          if (responseData['error'] != null) {
            throw NotFoundException(
                'Error en la respuesta del servidor: ${responseData['error']}');
          }
        }
      }
      rethrow;
    }
  }

  @override
  Future<String> addCotizaDetallePedido(List<Map<String, dynamic>> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      for (var detalle in data) {
        await _dioClient.post(
          '/insertDetalleCotiza',
          queryParameters: detalle,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
      return 'La cotización de pedido fue agregada con éxito';
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<CotizaModel> addCotizaPedido(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      // Construir query string manualmente para garantizar que todos los params lleguen
      final queryString = data.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      print('>>> COTIZA URL: /insertCotiza?$queryString');
      final result = await _dioClient.post(
        '/insertCotiza?$queryString',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final pedido = CotizaModel.fromJson(result.data);
      return pedido;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> addIdCotizaPedido(int idCotiza) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/rtoCotiza',
        queryParameters: {'id_cotiza': idCotiza},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return result.data['success'] as String;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> finalSesion(int idSesion) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.post(
        '/finalsesion',
        queryParameters: {'id_sesion': idSesion},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return result.data['success'] as String;
    } catch (_) {
      rethrow;
    }
  }
}
