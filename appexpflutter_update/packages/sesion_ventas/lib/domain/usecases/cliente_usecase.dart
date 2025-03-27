import 'package:fpdart/fpdart.dart';
import 'package:sesion_ventas/domain/entities/cliente_entity.dart';
import 'package:sesion_ventas/domain/repositories/cliente_repository.dart';
import 'package:sesion_ventas/exceptions/network_exception.dart';

class ClienteUsecase {
  final ClienteRepository clienteRepository;

  ClienteUsecase({required this.clienteRepository});

  Future<Either<NetworkException, List<ClienteEntity>>> getClientes(
      String nombre) async {
    return await clienteRepository.getClientes(nombre);
  }

  Future<Either<NetworkException, String>> updateClientes(
      Map<String, dynamic> data) async {
    return await clienteRepository.updateClientes(data);
  }

  Future<Either<NetworkException, String>> createsClientes(
      Map<String, dynamic> data) async {
    return await clienteRepository.createClientes(data);
  }
}
