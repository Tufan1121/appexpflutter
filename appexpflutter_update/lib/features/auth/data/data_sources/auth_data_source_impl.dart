import 'package:dio/dio.dart';
import 'package:api_client/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login/data/data_sources/auth_data_source.dart';
import 'package:login/data/models/auth_user_model.dart';

class AuthDataSourceImpl implements AuthDatasource {
  final DioClient _dioClient;

  AuthDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;
  final storage = const FlutterSecureStorage();

  @override
  Future<AuthUserModel> login(String email, String password, {bool forceLogin = false}) async {
    final Map<String, dynamic> body = {
      'grant_type': '',
      'username': email,
      'password': password,
      'scope': '',
      'client_id': '',
      'client_secret': '',
    };
    
    // Si forceLogin es true, agregar al body
    if (forceLogin) {
      body['force_login'] = 'true';
    }
    
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    
    // También enviar como header por si el backend lo espera así
    if (forceLogin) {
      headers['X-Force-Login'] = 'true';
    }
    
    try {
      final response = await _dioClient.post(
        '/token',
        data: body,
        queryParameters: forceLogin ? {'force_login': 'true'} : null,
        options: Options(headers: headers),
      );

      final authUserModel = AuthUserModel.fromJson(response.data);
      return authUserModel;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> logout([int? idUser]) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final response = await _dioClient.post('/logout',
          queryParameters: {'idUser': idUser},
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }));
      return response.data['detail'] as String;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<String> logoutByEmail(String email, [String? password]) async {
    try {
      // Intento 1: logout con username como query param
      final response = await _dioClient.post('/logout',
          queryParameters: {'username': email});
      return response.data['detail'] as String;
    } catch (_) {
      try {
        // Intento 2: logout con email como query param
        final response2 = await _dioClient.post('/logout',
            queryParameters: {'email': email});
        return response2.data['detail'] as String;
      } catch (_) {
        try {
          // Intento 3: logout con correo como query param
          final response3 = await _dioClient.post('/logout',
              queryParameters: {'correo': email});
          return response3.data['detail'] as String;
        } catch (_) {
          // Si todos fallan, retornamos para continuar con login
          return 'logout_attempted';
        }
      }
    }
  }
}
