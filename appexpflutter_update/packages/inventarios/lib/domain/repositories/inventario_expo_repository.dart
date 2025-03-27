import 'package:fpdart/fpdart.dart';
import 'package:inventarios/config/exceptions/network_exception.dart';
import 'package:inventarios/domain/entities/medidas_entity_inv.dart';
import 'package:inventarios/domain/entities/producto_expo_entity.dart';

abstract interface class InventarioExpoRepository {
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoExpo(
      Map<String, dynamic> data);
  Future<Either<NetworkException, List<ProductoExpoEntity>>> getProductoGlobal(
      Map<String, dynamic> data);
  Future<Either<NetworkException, List<MedidasEntityInv>>> getMedidas();
}
