import 'package:dio/dio.dart';
import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthDataSourceImpl implements AuthDatasource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  AuthDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;
  @override
  Future<String> login(String email, String password) async {
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
      print(response.data['access_token']);
      return '';
      // return response.data['access_token'] as String;
    } catch (_) {
      rethrow;
    }
  }
}
