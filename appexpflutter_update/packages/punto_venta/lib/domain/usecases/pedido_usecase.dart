import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/domain/entities/pedido_entity.dart';
import 'package:punto_venta/domain/repositories/pedido_repository.dart';
import 'package:fpdart/fpdart.dart';

class PedidoVentaUsecase {
  final PedidoVentaRepository pedidoRepository;

  PedidoVentaUsecase({required this.pedidoRepository});

  Future<Either<NetworkException, PedidoEntity>> addPedido(
      Map<String, dynamic> data) {
    return pedidoRepository.addPedido(data);
  }

  Future<Either<NetworkException, String>> addDetallePedido(
      List<Map<String, dynamic>> data) {
    return pedidoRepository.addDetallePedido(data);
  }
}
