import 'package:appexpflutter_update/config/custom_exceptions/not_found_expection.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/precios/data/data_sources/producto_data_source.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/precios/domain/repositories/producto_repository.dart';

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
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
