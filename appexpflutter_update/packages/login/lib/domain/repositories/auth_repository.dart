import 'package:fpdart/fpdart.dart';
import 'package:login/config/exceptions/network_exception.dart';
import 'package:login/domain/entities/auth_user_entity.dart';

abstract interface class AuthRepository {
  
  Future<Either<NetworkException, AuthUserEntity>> login(
      String email, String password, {bool forceLogin = false});

  Future<Either<NetworkException, String>> logout([int? idUser]);
  
  Future<Either<NetworkException, String>> logoutByEmail(String email, [String? password]);
}
