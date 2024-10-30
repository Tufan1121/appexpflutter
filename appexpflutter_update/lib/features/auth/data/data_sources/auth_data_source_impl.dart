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
  Future<AuthUserModel> login(String email, String password) async {
    final Map<String, dynamic> body = {
      'grant_type': '',
      'username': email,
      'password': password,
      'scope': '',
      'client_id': '',
      'client_secret': '',
    };
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    try {
      final response = await _dioClient.post(
        '/token',
        data: body,
        options: Options(headers: headers),
      );

      final authUserModel = AuthUserModel.fromJson(response.data);
      //print(authUserModel.accessToken);
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
      return response.data as String;
    } catch (_) {
      rethrow;
    }
  }
}
