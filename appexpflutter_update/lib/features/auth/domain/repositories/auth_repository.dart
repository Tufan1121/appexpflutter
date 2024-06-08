import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  
  Future<Either<NetworkException, String>> login(
      String email, String password);
}
