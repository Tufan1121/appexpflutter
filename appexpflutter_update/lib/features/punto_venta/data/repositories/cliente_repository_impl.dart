import 'package:appexpflutter_update/features/punto_venta/domain/repositories/cliente_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/cliente/cliente_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/cliente_entity.dart';
import 'package:api_client/exceptions/network_exception.dart';


class ClienteRepositoryImpl implements ClienteVentaRepository {
  final ClienteDataVentaSource clienteDataSource;

  ClienteRepositoryImpl({required this.clienteDataSource});

  @override
  Future<Either<NetworkException, List<ClienteEntity>>> getClientes(
      String nombre) async {
    try {
      final result = await clienteDataSource.getCliente(nombre);
      final clientesEntity = result.map((model) => model.toEntity()).toList();
      return Right(clientesEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> createClientes(
      Map<String, dynamic> data) async {
    try {
      final result = await clienteDataSource.createClientes(data);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> updateClientes(
      Map<String, dynamic> data) async {
    try {
      final result = await clienteDataSource.updateClientes(data);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
