import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cotiza_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/sesion_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PedidoRepository {
  Future<Either<NetworkException, PedidoEntity>> addPedido(
      Map<String, dynamic> data);
  Future<Either<NetworkException, String>> addDetallePedido(
      List<Map<String, dynamic>> data);
  Future<Either<NetworkException, String>> addIdPedido(int idPedido);

  Future<Either<NetworkException, String>> addIdCotizaPedido(int idPedido);
  Future<Either<NetworkException, String>> addSesionDetallePedido(
      List<Map<String, dynamic>> data);

  Future<Either<NetworkException, SesionEntity>> addSesionPedido(
      Map<String, dynamic> data);

  Future<Either<NetworkException, String>> addCotizaDetallePedido(
      List<Map<String, dynamic>> data);

  Future<Either<NetworkException, CotizaEntity>> addCotizaPedido(
      Map<String, dynamic> data);
}
