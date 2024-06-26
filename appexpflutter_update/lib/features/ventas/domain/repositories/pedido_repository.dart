import 'package:api_client/exceptions/network_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PedidoRepository {
  Future<Either<NetworkException, int>> addPedido(Map<String, dynamic> data);
  Future<Either<NetworkException, String>> addDetallePedido(Map<String, dynamic> data);
}
