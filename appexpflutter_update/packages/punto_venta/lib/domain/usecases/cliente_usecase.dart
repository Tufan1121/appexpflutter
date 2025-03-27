import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/domain/entities/cliente_entity.dart';
import 'package:punto_venta/domain/repositories/cliente_repository.dart';
import 'package:fpdart/fpdart.dart';

class ClienteVentaUsecase {
  final ClienteVentaRepository clienteRepository;

  ClienteVentaUsecase({required this.clienteRepository});

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
