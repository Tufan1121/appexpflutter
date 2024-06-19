import 'package:appexpflutter_update/config/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/cliente_data_source.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/repositories/cliente_repository.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteDataSource clienteDataSource;

  ClienteRepositoryImpl({required this.clienteDataSource});
  @override
  Future<Either<NetworkException, ClienteEntity>> clienteNuevo(String nombre,
      String apellido, String telefono, String correo, String factura,
      {String? dirreccion,
      String? rfc,
      String? tipoPersona,
      String? usoCfdi,
      String? empresa,
      String? cp}) {
    // TODO: implement clienteNuevo
    throw UnimplementedError();
  }

  @override
  Future<Either<NetworkException, List<ClienteEntity>>> getClientes(
      String nombre) async {
    try {
      final result = await clienteDataSource.getCliente(nombre);
      final clientesEntity = result.map((model) => model.toEntity()).toList();
      return Right(clientesEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
