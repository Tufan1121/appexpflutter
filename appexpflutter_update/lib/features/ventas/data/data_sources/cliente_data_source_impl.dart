import 'package:appexpflutter_update/config/custom_exceptions/not_found_expection.dart';
import 'package:dio/dio.dart';
import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/cliente_data_source.dart';
import 'package:appexpflutter_update/features/ventas/data/models/cliente_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClienteDataSourceImpl implements ClienteDataSource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  ClienteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<ClienteModel>> getCliente(String name) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get(
        '/buscacliente',
        queryParameters: {'nombre': name},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      List<dynamic> jsonList = result.data;
      if (jsonList.isNotEmpty) {
        final listClientes =
            jsonList.map((json) => ClienteModel.fromJson(json)).toList();
        return listClientes;
      } else {
        throw NotFoundException('Introduzca un cliente');
      }
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> updateClientes(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.put(
        '/updateClientesExpo',
        queryParameters: data,
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
