import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/inventarios/domain/repositories/inventario_expo_repository.dart';
import 'package:fpdart/fpdart.dart';

class InventarioExpoUsecase {
  final InventarioExpoRepository inventarioExpoRepository;

  InventarioExpoUsecase({required this.inventarioExpoRepository});
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoExpo(
      Map<String, dynamic> data) async {
    return await inventarioExpoRepository.getProductoExpo(data);
  }

  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoGlobal(
      Map<String, dynamic> data) async {
    return await inventarioExpoRepository.getProductoGlobal(data);
  }
}
