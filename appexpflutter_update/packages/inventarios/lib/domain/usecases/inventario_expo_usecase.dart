import 'package:fpdart/fpdart.dart';
import 'package:inventarios/config/exceptions/network_exception.dart';
import 'package:inventarios/domain/entities/medidas_entity_inv.dart';
import 'package:inventarios/domain/entities/producto_expo_entity.dart';
import 'package:inventarios/domain/repositories/inventario_expo_repository.dart';

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

  Future<Either<NetworkException, List<MedidasEntityInv>>> getMedidas() async {
    return await inventarioExpoRepository.getMedidas();
  }
}
