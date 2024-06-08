import 'package:fpdart/fpdart.dart';
import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/auth/domain/repositories/auth_repository.dart';

class AuthUsecase {
  final AuthRepository authRepository;

  AuthUsecase({required this.authRepository});

  Future<Either<NetworkException, String>> login(
      String email, String password) async {
    return await authRepository.login(email, password);
  }
}
