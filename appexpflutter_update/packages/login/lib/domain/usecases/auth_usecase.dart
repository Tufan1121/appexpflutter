import 'package:fpdart/fpdart.dart';
import 'package:login/config/exceptions/network_exception.dart';
import 'package:login/domain/entities/auth_user_entity.dart';
import 'package:login/domain/repositories/auth_repository.dart';

class AuthUsecase {
  final AuthRepository authRepository;

  AuthUsecase({required this.authRepository});

  Future<Either<NetworkException, AuthUserEntity>> login(
      String email, String password, {bool forceLogin = false}) async {
    return await authRepository.login(email, password, forceLogin: forceLogin);
  }

  Future<Either<NetworkException, String>> logout([int? idUser ]) async {
    return await authRepository.logout();
  }

  Future<Either<NetworkException, String>> logoutByEmail(String email, [String? password]) async {
    return await authRepository.logoutByEmail(email, password);
  }
}
