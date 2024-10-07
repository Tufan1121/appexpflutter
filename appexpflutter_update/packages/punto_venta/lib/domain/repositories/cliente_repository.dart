import 'package:fpdart/fpdart.dart';
import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/domain/entities/cliente_entity.dart';

abstract interface class ClienteVentaRepository {
  Future<Either<NetworkException, List<ClienteEntity>>> getClientes(
      String nombre);
  Future<Either<NetworkException, String>> updateClientes(
      Map<String, dynamic> data);
  Future<Either<NetworkException, String>> createClientes(
      Map<String, dynamic> data);
}
