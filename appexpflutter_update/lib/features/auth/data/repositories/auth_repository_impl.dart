import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source.dart';
import 'package:appexpflutter_update/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource authDatasource;

  AuthRepositoryImpl({required this.authDatasource});
  @override
  Future<Either<NetworkException, String>> login(
      String email, String password) async {
    try {
      final result = await authDatasource.login(email, password);
      return Right(result);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
