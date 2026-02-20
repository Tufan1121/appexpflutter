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
      
      // DEBUG: Ver estructura completa de la respuesta
      print('═══════════════════════════════════════════════════════');
      print('DEBUG /cuentas/ - Respuesta completa:');
      print(result.data);
      print('DEBUG /cuentas/ - Tipo: ${result.data.runtimeType}');
      
      if (result.data is List && (result.data as List).isNotEmpty) {
        print('DEBUG /cuentas/ - Primer elemento:');
        print((result.data as List).first);
        print('DEBUG /cuentas/ - Campos del primer elemento:');
        (result.data as List).first.forEach((key, value) {
          print('  $key: $value (${value.runtimeType})');
        });
      }
      print('═══════════════════════════════════════════════════════');
      
      return (result.data as List).map((e) => CuentaModel.fromJson(e)).toList();
    } catch (e) {
      print('ERROR en getCuentas: $e');
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
      
      // DEBUG: Ver estructura completa de la respuesta
      print('═══════════════════════════════════════════════════════');
      print('DEBUG /terminales/ - Respuesta completa:');
      print(result.data);
      print('DEBUG /terminales/ - Tipo: ${result.data.runtimeType}');
      
      if (result.data is List && (result.data as List).isNotEmpty) {
        print('DEBUG /terminales/ - Primer elemento:');
        print((result.data as List).first);
        print('DEBUG /terminales/ - Campos del primer elemento:');
        (result.data as List).first.forEach((key, value) {
          print('  $key: $value (${value.runtimeType})');
        });
      }
      print('═══════════════════════════════════════════════════════');
      
      return (result.data as List).map((e) => TerminalModel.fromJson(e)).toList();
    } catch (e) {
      print('ERROR en getTerminales: $e');
      return [];
    }
  }
}
