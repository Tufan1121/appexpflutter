import 'package:fpdart/fpdart.dart';
import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/domain/entities/pedido_entity.dart';

abstract interface class PedidoVentaRepository {
  Future<Either<NetworkException, PedidoEntity>> addPedido(
      Map<String, dynamic> data);
  Future<Either<NetworkException, String>> addDetallePedido(
      List<Map<String, dynamic>> data);
}
