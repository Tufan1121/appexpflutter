import 'package:fpdart/fpdart.dart';
import 'package:precios/config/exceptions/network_exception.dart';
import 'package:precios/domain/entities/producto_entity.dart';

abstract interface class ProductoRepository {
  Future<Either<NetworkException, ProductoEntity>> getProductInfo(String productKey);
  Future<Either<NetworkException, List<ProductoEntity>>> getRelativedProducts(String descripcion, String diseno, String producto );
  Future<Either<NetworkException, List<ProductoEntity>>> getIBodegaProducts(Map<String, dynamic> data );
}
