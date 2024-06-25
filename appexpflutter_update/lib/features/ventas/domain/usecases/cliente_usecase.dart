import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/repositories/cliente_repository.dart';
import 'package:fpdart/fpdart.dart';

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

  Future<Either<NetworkException, bool>> createsClientes(
      Map<String, dynamic> data) async {
    return await clienteRepository.createClientes(data);
  }
}
