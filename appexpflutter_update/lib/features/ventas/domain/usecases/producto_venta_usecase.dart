import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/precios/domain/repositories/producto_repository.dart';
import 'package:fpdart/fpdart.dart';

class ProductoVentaUsecase {
  final ProductoRepository productoRepository;

  ProductoVentaUsecase({required this.productoRepository});

  Future<Either<NetworkException, ProductoEntity>> getProductInfo(
      String productKey) async {
    return await productoRepository.getProductInfo(productKey);
  }

  Future<Either<NetworkException, List<ProductoEntity>>> getIBodegaProducts(
      Map<String, dynamic> data) async {
    return await productoRepository.getIBodegaProducts(data);
  }
}
