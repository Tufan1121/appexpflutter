import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// El cliente no tiene correo registrado o es inválido (400 "Correo ...").
class CorreoClienteException implements Exception {
  final String message;
  const CorreoClienteException(this.message);

  @override
  String toString() => message;
}

/// El cliente (o el ticket) no tiene teléfono o es inválido (400 "Telefono ...").
class TelefonoClienteException implements Exception {
  final String message;
  const TelefonoClienteException(this.message);

  @override
  String toString() => message;
}

/// Envío de cotizaciones y tickets al cliente desde el backend (mainTienda):
/// WhatsApp desde el número central y correo con el PDF adjunto. Mismos
/// endpoints y nombres que en la app de expo.
class EnvioDocumentosDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  EnvioDocumentosDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  Future<Options> _opciones() async {
    final token = await storage.read(key: 'accessToken');
    return Options(
      headers: {'Authorization': 'Bearer $token'},
      // Síncrono: puede generar el PDF y esperar la respuesta de Meta.
      receiveTimeout: const Duration(seconds: 45),
    );
  }

  /// [detail] del error del backend; 400 con [prefijo] es el dato del cliente
  /// que falta (la app ofrece capturarlo).
  Never _error(DioException e, String prefijo, String porDefecto) {
    final data = e.response?.data;
    final detail = data is Map ? data['detail'] : null;
    if (e.response?.statusCode == 400 &&
        detail is String &&
        detail.startsWith(prefijo)) {
      throw prefijo == 'Correo'
          ? CorreoClienteException(detail)
          : TelefonoClienteException(detail);
    }
    throw Exception(detail is String ? detail : porDefecto);
  }

  /// Manda la cotización por WhatsApp. Con [telefono] vacío el backend usa el
  /// del cliente; si viene (capturado al enviar) se manda con [ladaPais] y, con
  /// [guardar], se queda en el cliente. En tienda solo hay cotizaciones:
  /// [cotizacion] e [idExpo] se aceptan por compatibilidad con expo.
  Future<String> enviarPedidoWhatsapp(
      {required String pedidos,
      int? idExpo,
      String telefono = '',
      String ladaPais = '',
      bool guardar = false,
      bool cotizacion = true}) async {
    try {
      final result = await _dioClient.post(
        '/enviarCotizacionWhatsapp',
        queryParameters: {
          'pedidos': pedidos,
          if (telefono.trim().isNotEmpty) 'telefono': telefono.trim(),
          if (ladaPais.trim().isNotEmpty) 'lada_pais': ladaPais.trim(),
          if (guardar) 'guardar': 1,
        },
        options: await _opciones(),
      );
      // Solo los últimos 4 dígitos: el vendedor no necesita ver el número
      final tel = (result.data['telefono'] ?? '').toString();
      final fin = tel.length > 4 ? tel.substring(tel.length - 4) : tel;
      return 'WhatsApp enviado al cliente (…$fin)';
    } on DioException catch (e) {
      _error(e, 'Telefono', 'No se pudo enviar el WhatsApp');
    }
  }

  /// Manda el ticket de punto de venta por WhatsApp desde el número central.
  /// Mismas reglas que [enviarPedidoWhatsapp]; el teléfono capturado se guarda
  /// en el ticket.
  Future<String> enviarTicketWhatsapp(
      {required String documen,
      String telefono = '',
      String ladaPais = '',
      bool guardar = false}) async {
    try {
      await _dioClient.post(
        '/enviarTicketWhatsapp',
        queryParameters: {
          'documen': documen,
          if (telefono.trim().isNotEmpty) 'telefono': telefono.trim(),
          if (ladaPais.trim().isNotEmpty) 'lada_pais': ladaPais.trim(),
          if (guardar) 'guardar': 1,
        },
        options: await _opciones(),
      );
      return 'WhatsApp enviado';
    } on DioException catch (e) {
      _error(e, 'Telefono', 'No se pudo enviar el WhatsApp');
    }
  }

  /// Manda la cotización por correo con el PDF adjunto. Sin [correo] se usa el
  /// del cliente; con [guardar] el capturado se queda en el cliente.
  Future<String> enviarDocumentoCorreo(
      {required String pedidos,
      int? idExpo,
      String correo = '',
      bool guardar = false,
      bool cotizacion = true}) async {
    try {
      await _dioClient.post(
        '/enviarCotizacionCorreo',
        queryParameters: {
          'pedidos': pedidos,
          if (correo.trim().isNotEmpty) 'correo': correo.trim(),
          if (guardar) 'guardar': 1,
        },
        options: await _opciones(),
      );
      return 'Correo enviado';
    } on DioException catch (e) {
      _error(e, 'Correo', 'No se pudo enviar el correo');
    }
  }
}
