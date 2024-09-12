
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:precios/config/exceptions/network_exception.dart';
import 'package:precios/config/exceptions/not_found_expection.dart';
import 'package:precios/data/data_sources/producto_data_source.dart';
import 'package:precios/domain/entities/producto_entity.dart';
import 'package:precios/domain/repositories/producto_repository.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoDataSource productoDataSource;

  ProductoRepositoryImpl({required this.productoDataSource});
  @override
  Future<Either<NetworkException, ProductoEntity>> getProductInfo(
      String productKey) async {
    try {
      final result = await productoDataSource.getProductInfo(productKey);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, List<ProductoEntity>>> getRelativedProducts(
      String descripcion, String diseno, String producto) async {
    try {
      final result = await productoDataSource.getRelativedProducts(
          descripcion, diseno, producto);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productosEntity = result.map((model) => model.toEntity()).toList();
      return Right(productosEntity);
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
  Future<Either<NetworkException, List<ProductoEntity>>> getIBodegaProducts(
      Map<String, dynamic> data) async {
    try {
      final result = await productoDataSource.getIBodegaProducts(data);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productosEntity = result.map((model) => model.toEntity()).toList();
      return Right(productosEntity);
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
