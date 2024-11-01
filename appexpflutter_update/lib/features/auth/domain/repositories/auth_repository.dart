import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/auth/domain/entities/auth_user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<NetworkException, AuthUserEntity>> login(
      String email, String password);

  Future<Either<NetworkException, String>> logout([int? idUser]);
}
