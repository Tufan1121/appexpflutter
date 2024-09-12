
import 'package:fpdart/fpdart.dart';
import 'package:sesion_ventas/domain/entities/cliente_entity.dart';
import 'package:sesion_ventas/exceptions/network_exception.dart';

abstract interface class ClienteRepository {
  Future<Either<NetworkException, List<ClienteEntity>>> getClientes(
      String nombre);
  Future<Either<NetworkException, String>> updateClientes(
      Map<String, dynamic> data);
  Future<Either<NetworkException, String>> createClientes(
      Map<String, dynamic> data);
}
