import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/cliente_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ClienteVentaRepository {
  Future<Either<NetworkException, List<ClienteEntity>>> getClientes(
      String nombre);
  Future<Either<NetworkException, String>> updateClientes(
      Map<String, dynamic> data);
  Future<Either<NetworkException, String>> createClientes(
      Map<String, dynamic> data);
}
