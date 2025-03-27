import 'package:fpdart/fpdart.dart';
import 'package:sesion_ventas/domain/entities/producto_entity.dart';
import 'package:sesion_ventas/exceptions/network_exception.dart';
abstract interface class ProductoRepository {
  Future<Either<NetworkException, ProductoEntity>> getProductInfo(String productKey);
  Future<Either<NetworkException, List<ProductoEntity>>> getRelativedProducts(String descripcion, String diseno, String producto );
  Future<Either<NetworkException, List<ProductoEntity>>> getIBodegaProducts(Map<String, dynamic> data );
}
