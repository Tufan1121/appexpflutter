import 'package:fpdart/fpdart.dart';
import 'package:sesion_ventas/domain/entities/producto_entity.dart';
import 'package:sesion_ventas/domain/repositories/producto_repository.dart';
import 'package:sesion_ventas/exceptions/network_exception.dart';

class ProductoUsecase {
  final ProductoRepository productoRepository;

  ProductoUsecase({required this.productoRepository});

  Future<Either<NetworkException, ProductoEntity>> getProductInfo(
      String productKey) async {
    return await productoRepository.getProductInfo(productKey);
  }

  Future<Either<NetworkException, List<ProductoEntity>>> getRelativedProducts(
      String descripcion, String diseno, String producto) async {
    return await productoRepository.getRelativedProducts(
        descripcion, diseno, producto);
  }

  Future<Either<NetworkException, List<ProductoEntity>>> getIBodegaProducts(
      Map<String, dynamic> data) async {
    return await productoRepository.getIBodegaProducts(data);
  }
}
