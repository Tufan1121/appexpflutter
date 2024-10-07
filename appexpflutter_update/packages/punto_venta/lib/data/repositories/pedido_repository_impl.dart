import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/config/exceptions/not_found_expection.dart';
import 'package:punto_venta/data/data_sources/pedido/pedido_data_source.dart';
import 'package:punto_venta/domain/repositories/pedido_repository.dart';
import 'package:punto_venta/domain/entities/pedido_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';



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
