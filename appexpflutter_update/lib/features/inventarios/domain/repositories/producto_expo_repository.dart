import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/producto_expo_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ProductoExpoRepository {
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoExpo(Map<String, dynamic> map);
}
