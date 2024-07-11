import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cotiza_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/sesion_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/repositories/pedido_repository.dart';

class PedidoRepositoryImpl implements PedidoRepository {
  final PedidoDataSource pedidoDataSource;

  PedidoRepositoryImpl({required this.pedidoDataSource});

  @override
  Future<Either<NetworkException, String>> addDetallePedido(
      List<Map<String, dynamic>> data) async {
    try {
      final result = await pedidoDataSource.addDetallePedido(data);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, PedidoEntity>> addPedido(
      Map<String, dynamic> data) async {
    try {
      final result = await pedidoDataSource.addPedido(data);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> addIdPedido(int idPedido) async {
    try {
      final result = await pedidoDataSource.addIdPedido(idPedido);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> addSesionDetallePedido(
      List<Map<String, dynamic>> data) async {
    try {
      final result = await pedidoDataSource.addSesionDetallePedido(data);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, SesionEntity>> addSesionPedido(
      Map<String, dynamic> data) async {
    try {
      final result = await pedidoDataSource.addSesionPedido(data);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> addCotizaDetallePedido(
      List<Map<String, dynamic>> data) async {
    try {
      final result = await pedidoDataSource.addCotizaDetallePedido(data);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, CotizaEntity>> addCotizaPedido(
      Map<String, dynamic> data) async {
    try {
      final result = await pedidoDataSource.addCotizaPedido(data);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> addIdCotizaPedido(
      int idCotiza) async {
    try {
      final result = await pedidoDataSource.addIdCotizaPedido(idCotiza);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, String>> finalSesion(int idSesion) async {
    try {
      final result = await pedidoDataSource.finalSesion(idSesion);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
