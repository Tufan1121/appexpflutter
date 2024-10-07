import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:punto_venta/domain/repositories/inventario_expo_repository.dart';
import 'package:fpdart/fpdart.dart';

class InventarioExpoVentaUsecase {
  final InventarioExpoVentaRepository inventarioExpoRepository;

  InventarioExpoVentaUsecase({required this.inventarioExpoRepository});
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductosExpo(
      Map<String, dynamic> data) async {
    return await inventarioExpoRepository.getProductosExpo(data);
  }

  Future<Either<NetworkException, ProductoExpoEntity>> getProductoExpo(
      Map<String, dynamic> data) async {
    return await inventarioExpoRepository.getProductoExpo(data);
  }
}
