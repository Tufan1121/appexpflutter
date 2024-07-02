import 'package:appexpflutter_update/features/inventarios/data/data_sources/inventario_expo_data_source.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/producto_expo_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/inventarios/domain/repositories/inventario_expo_repository.dart';

class InventarioExpoRepositoryImpl implements InventarioExpoRepository {
  final InventarioExpoDataSource inventarioExpoDataSource;

  InventarioExpoRepositoryImpl({required this.inventarioExpoDataSource});
  @override
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoExpo(
      Map<String, dynamic> data) async {
    try {
      final result = await inventarioExpoDataSource.getProductoExpo(data);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productosExpoEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(productosExpoEntity);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }
  
  @override
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoGlobal(Map<String, dynamic> data) async{
    try {
      final result = await inventarioExpoDataSource.getProductoGlobal(data);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productosExpoEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(productosExpoEntity);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }
}
