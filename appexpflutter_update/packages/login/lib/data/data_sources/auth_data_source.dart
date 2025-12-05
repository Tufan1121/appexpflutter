
import 'package:login/data/models/auth_user_model.dart';

abstract interface class AuthDatasource {
  Future<AuthUserModel> login(String email, String password, {bool forceLogin = false});
  Future<String> logout([int? idUser]);
  Future<String> logoutByEmail(String email, [String? password]);
}
