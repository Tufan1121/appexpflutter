import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/payment_info/payment_info_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/cuenta_model.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/terminal_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentInfoDataSourceImpl implements PaymentInfoDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  PaymentInfoDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<CuentaModel>> getCuentas() async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get(
        '/cuentas/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return (result.data as List).map((e) => CuentaModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final error = _error(e);
      if (error is _SinRegistros) return [];
      throw error;
    }
  }

  @override
  Future<List<TerminalModel>> getTerminales() async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get(
        '/terminales/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return (result.data as List).map((e) => TerminalModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final error = _error(e);
      if (error is _SinRegistros) return [];
      throw error;
    }
  }

  /// El endpoint responde 404 "No se encontraron ..." cuando la tienda no tiene
  /// registros (lista vacía). Un 404 "Not Found" es que el backend aún no tiene
  /// la ruta; eso y cualquier otra falla se muestran en la pantalla de pagos.
  Object _error(DioException e) {
    final data = e.response?.data;
    final detalle = data is Map ? (data['detail'] ?? '').toString() : '';
    if (e.response?.statusCode == 404 && detalle.startsWith('No se encontraron')) {
      return const _SinRegistros();
    }
    if (e.response?.statusCode == 404) {
      return Exception('el servidor no tiene esta consulta (actualiza mainTienda)');
    }
    return Exception(detalle.isNotEmpty ? detalle : (e.message ?? 'sin conexión'));
  }
}

class _SinRegistros implements Exception {
  const _SinRegistros();
}
