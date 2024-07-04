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
      List<Map<String, dynamic>> data) {
    return pedidoRepository.addDetallePedido(data);
  }

  Future<Either<NetworkException, PedidoEntity>> addSesionPedido(
      Map<String, dynamic> data) {
    return pedidoRepository.addSesionPedido(data);
  }

  Future<Either<NetworkException, String>> addSesionDetallePedido(
      List<Map<String, dynamic>> data) {
    return pedidoRepository.addSesionDetallePedido(data);
  }

  Future<Either<NetworkException, String>> addIdPedido(int idPedido) {
    return pedidoRepository.addIdPedido(idPedido);
  }
}
