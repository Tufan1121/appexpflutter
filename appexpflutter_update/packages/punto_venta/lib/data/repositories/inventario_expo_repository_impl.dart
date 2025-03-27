import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/config/exceptions/not_found_expection.dart';
import 'package:punto_venta/data/data_sources/inventario_expo/inventario_expo_data_source.dart';
import 'package:punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:punto_venta/domain/repositories/inventario_expo_repository.dart';

class InventarioExpoVentaRepositoryImpl
    implements InventarioExpoVentaRepository {
  final InventarioExpoVentaDataSource inventarioExpoDataSource;

  InventarioExpoVentaRepositoryImpl({required this.inventarioExpoDataSource});
  @override
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductosExpo(
      Map<String, dynamic> data) async {
    try {
      final result = await inventarioExpoDataSource.getProductosExpo(data);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productosExpoEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(productosExpoEntity);
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
  Future<Either<NetworkException, ProductoExpoEntity>> getProductoExpo(
      Map<String, dynamic> data) async {
    try {
      final result = await inventarioExpoDataSource.getProductoExpo(data);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
