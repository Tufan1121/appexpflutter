import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/repositories/pedido_repository.dart';

class PedidoRepositoryImpl implements PedidoRepository {
  final PedidoDataSource pedidoDataSource;

  PedidoRepositoryImpl({required this.pedidoDataSource});

  @override
  Future<Either<NetworkException, String>> addDetallePedido(
      List<Map<String, dynamic>> data) async {
    try {
      final result = await pedidoDataSource.addDetallePedido(data);
      return Right(result);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, PedidoEntity>> addPedido(
      Map<String, dynamic> data) async {
    try {
      final result = await pedidoDataSource.addPedido(data);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
