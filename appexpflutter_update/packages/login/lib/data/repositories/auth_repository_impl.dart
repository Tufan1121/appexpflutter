import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:login/config/exceptions/network_exception.dart';
import 'package:login/data/data_sources/auth_data_source.dart';
import 'package:login/domain/entities/auth_user_entity.dart';
import 'package:login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource authDatasource;

  AuthRepositoryImpl({required this.authDatasource});
  @override
  Future<Either<NetworkException, AuthUserEntity>> login(
      String email, String password) async {
    try {
      final result = await authDatasource.login(email, password);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> logout([int? idUser]) async {
    try {
      final result = await authDatasource.logout();
      return Right(result);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
