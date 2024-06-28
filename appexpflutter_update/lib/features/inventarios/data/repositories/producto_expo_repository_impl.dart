import 'package:appexpflutter_update/features/inventarios/data/data_sources/inventario_expo_data_source.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/producto_expo_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/inventarios/domain/repositories/producto_expo_repository.dart';

class ProductoExpoRepositoryImpl implements ProductoExpoRepository {
  final InventarioExpoDataSource inventarioExpoDataSource;

  ProductoExpoRepositoryImpl({required this.inventarioExpoDataSource});
  @override
   Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoExpo(
      Map<String, dynamic> map) async {
    try {
      final result = await inventarioExpoDataSource.getProductoExpo(map);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productosExpoEntity = result.map((model) => model.toEntity()).toList();
      return Right(productosExpoEntity);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }
}
