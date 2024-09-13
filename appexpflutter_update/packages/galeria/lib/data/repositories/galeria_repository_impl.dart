import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:galeria/config/exceptions/network_exception.dart';
import 'package:galeria/config/exceptions/not_found_expection.dart';
import 'package:galeria/data/data_sources/galeria_data_source.dart';
import 'package:galeria/domain/entities/galeria_entity.dart';
import 'package:galeria/domain/entities/medidas_entity.dart';
import 'package:galeria/domain/entities/producto_entity.dart';
import 'package:galeria/domain/entities/producto_inv_entity.dart';
import 'package:galeria/domain/entities/tabla_precio_entity.dart';
import 'package:galeria/domain/repositories/galeria_repository.dart';

class GaleriaRepositoryImpl implements GaleriaRepository {
  final GaleriaDataSource galeriaDataSource;

  GaleriaRepositoryImpl({required this.galeriaDataSource});
  @override
  Future<Either<NetworkException, List<ProductoInvEntity>>> getgalinventario(
      String descripcion, String diseno) async {
    try {
      final result =
          await galeriaDataSource.getgalinventario(descripcion, diseno);
      // Mapear la lista de ProductoInvModel a ProductoInvEntity usando toEntity()
      final productosInventarioEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(productosInventarioEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }

  @override
  Future<Either<NetworkException, List<GaleriaEntity>>> getgallery(
      {String? descripcion, int? regg}) async {
    try {
      final result = await galeriaDataSource.getgallery(
          descripcion: descripcion, regg: regg);
      // Mapear la lista de GaleriaModel a GaleriaEntity usando toEntity()
      final galeriaEntity = result.map((model) => model.toEntity()).toList();
      return Right(galeriaEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }

  @override
  Future<Either<NetworkException, List<ProductoGalEntity>>> getgallerypics(
      String descripcion) async {
    try {
      final result = await galeriaDataSource.getgallerypics(descripcion);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productoEntity = result.map((model) => model.toEntity()).toList();
      return Right(productoEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, List<MedidasEntity>>> getgalmedidas(
      String descripcion, String diseno) async {
    try {
      final result = await galeriaDataSource.getgalmedidas(descripcion, diseno);
      // Mapear la lista de MedidasModel a MedidasEntity usando toEntity()
      final medidasEntity = result.map((model) => model.toEntity()).toList();
      return Right(medidasEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }

  @override
  Future<Either<NetworkException, List<TablaPreciosEntity>>> getTablaPrecio(String descripcion, String diseno) async {
    try {
      final result = await galeriaDataSource.getTablaPrecio(descripcion, diseno);
      // Mapear la lista de TablaPrecioModel a TablaPreciosEntity usando toEntity()
      final tablaPrecioEntity = result.map((model) => model.toEntity()).toList();
      return Right(tablaPrecioEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }
}
