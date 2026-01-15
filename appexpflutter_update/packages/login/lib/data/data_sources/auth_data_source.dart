
import 'package:login/data/models/auth_user_model.dart';

abstract interface class AuthDatasource {
  Future<AuthUserModel> login(String email, String password);
  Future<String> logout([int? idUser]);
}
