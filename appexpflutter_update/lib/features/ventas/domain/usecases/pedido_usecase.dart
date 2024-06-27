import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/repositories/pedido_repository.dart';
import 'package:fpdart/fpdart.dart';

class PedidoUsecase {
  final PedidoRepository pedidoRepository;

  PedidoUsecase({required this.pedidoRepository});

  Future<Either<NetworkException, PedidoEntity>> addPedido(
      Map<String, dynamic> data) {
    return pedidoRepository.addPedido(data);
  }

  Future<Either<NetworkException, String>> addDetallePedido(
      Map<String, dynamic> data) {
    return pedidoRepository.addDetallePedido(data);
  }
}
