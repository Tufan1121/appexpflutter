import 'package:appexpflutter_update/features/auth/domain/entities/auth_user_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/auth/domain/repositories/auth_repository.dart';

class AuthUsecase {
  final AuthRepository authRepository;

  AuthUsecase({required this.authRepository});

  Future<Either<NetworkException, AuthUserEntity>> login(
      String email, String password) async {
    return await authRepository.login(email, password);
  }
}
