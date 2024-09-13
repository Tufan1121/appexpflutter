import 'package:dio/dio.dart';
import 'package:api_client/api_client.dart';
import 'package:login/data/data_sources/auth_data_source.dart';
import 'package:login/data/models/auth_user_model.dart';


class AuthDataSourceImpl implements AuthDatasource {
  final DioClient _dioClient;

  AuthDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;
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
      // final token = response.data['access_token'] as String;
      return authUserModel;
    } catch (_) {
      rethrow;
    }
  }
}
