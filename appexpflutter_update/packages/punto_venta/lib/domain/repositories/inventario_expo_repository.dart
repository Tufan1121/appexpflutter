import 'package:fpdart/fpdart.dart';
import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/domain/entities/producto_expo_entity.dart';

abstract interface class InventarioExpoVentaRepository {
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductosExpo(
      Map<String, dynamic> data);
  Future<Either<NetworkException, ProductoExpoEntity>> getProductoExpo(
      Map<String, dynamic> data);
}
