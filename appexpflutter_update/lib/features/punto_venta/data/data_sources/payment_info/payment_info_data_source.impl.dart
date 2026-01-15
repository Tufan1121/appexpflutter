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
      // Assuming result.data is a List
      print('DEBUG: fetched cuentas: ${result.data}');
      return (result.data as List).map((e) => CuentaModel.fromJson(e)).toList();
    } catch (_) {
      // Return empty list on error to allow UI to function at least partially
      // or rethrow if strict
      // rethrow;
      // For now, let's return safe value or dummy data in case API fails
       return [];
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
      print('DEBUG: fetched terminales: ${result.data}');
      return (result.data as List).map((e) => TerminalModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
