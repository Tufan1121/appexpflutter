import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ProductoRepository {
  Future<Either<NetworkException, ProductoEntity>> getProductInfo(String productKey);
  Future<Either<NetworkException, List<ProductoEntity>>> getRelativedProducts(String descripcion, String diseno, String producto );
}
