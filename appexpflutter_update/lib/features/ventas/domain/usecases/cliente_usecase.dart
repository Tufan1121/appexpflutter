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
}
