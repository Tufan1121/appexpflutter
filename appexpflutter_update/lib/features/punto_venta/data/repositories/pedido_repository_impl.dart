import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/repositories/pedido_repository.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/pedido_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:api_client/exceptions/network_exception.dart';


class PedidoVentaRepositoryImpl implements PedidoVentaRepository {
  final PedidoDataVentaSource pedidoDataSource;

  PedidoVentaRepositoryImpl({required this.pedidoDataSource});

  @override
  Future<Either<NetworkException, String>> addDetallePedido(
      List<Map<String, dynamic>> data) async {
    try {
      final result = await pedidoDataSource.addDetallePedido(data);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
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
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
