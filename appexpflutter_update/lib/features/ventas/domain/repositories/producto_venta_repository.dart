import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ProductoVentaRepository {
  Future<Either<NetworkException, ProductoEntity>> getProductInfo(String productKey);
  Future<Either<NetworkException, List<ProductoEntity>>> getIBodegaProducts(Map<String, dynamic> data );
}
