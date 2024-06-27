import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PedidoRepository {
  Future<Either<NetworkException, PedidoEntity>> addPedido(Map<String, dynamic> data);
  Future<Either<NetworkException, String>> addDetallePedido(List<Map<String, dynamic>> data);
}
