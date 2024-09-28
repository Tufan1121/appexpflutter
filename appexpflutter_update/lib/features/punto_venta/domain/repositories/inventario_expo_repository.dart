import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class InventarioExpoVentaRepository {
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductosExpo(
      Map<String, dynamic> data);
  Future<Either<NetworkException, ProductoExpoEntity>> getProductoExpo(
      Map<String, dynamic> data);
}
