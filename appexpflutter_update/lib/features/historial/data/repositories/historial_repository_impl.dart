import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_cotiza_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_pedido_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/producto_entity.dart';

import 'package:appexpflutter_update/features/historial/domain/respositories/historial_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialDataSource historialDataSource;

  HistorialRepositoryImpl({required this.historialDataSource});
  @override
  Future<Either<NetworkException, List<HistorialPedidoEntity>>>
      getHistorialPedido(String parameter) async {
    try {
      final result = await historialDataSource.getHistorialPedido(parameter);
      final historialListEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(historialListEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, List<HistorialCotizaEntity>>>
      getHistorialCotiza(String parameter) async {
    try {
      final result = await historialDataSource.getHistorialCotiza(parameter);
      final historialListEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(historialListEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, List<HistorialSesionEntity>>>
      getHistorialSesion(String parameter) async {
    try {
      final result = await historialDataSource.getHistorialSesion(parameter);
      final historialListEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(historialListEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, List<DetalleSesionEntity>>>
      getHistorialDetalleSesion(String idSesion) async {
    try {
      final result =
          await historialDataSource.getHistorialDetalleSesion(idSesion);
      final historialListEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(historialListEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, ProductoEntity>> getProductInfo(
      String productKey) async {
    try {
      final result = await historialDataSource.getProductInfo(productKey);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
