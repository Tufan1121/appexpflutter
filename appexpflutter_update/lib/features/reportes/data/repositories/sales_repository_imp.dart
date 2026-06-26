import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/reportes/data/data_sources/sales_datasource.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/repositories/sales_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class SalesRepositoryImp implements SalesRepository {
  final SalesDatasource salesDatasource;

  SalesRepositoryImp({required this.salesDatasource});
  @override
  Future<Either<NetworkException, List<SalesPedidosEntity>>>
      getSalesPedidos({String? fechaini, String? fechafin}) async {
    try {
      final result = await salesDatasource.getSalesPedidos(
          fechaini: fechaini, fechafin: fechafin);
      final resultList = result.map((model) => model.toEntity()).toList();
      return Right(resultList);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, List<SalesTicketsEntity>>>
      getSalesTickets({String? fechaini, String? fechafin}) async {
    try {
      final result = await salesDatasource.getSalesTickets(
          fechaini: fechaini, fechafin: fechafin);
      final resultList = result.map((model) => model.toEntity()).toList();
      return Right(resultList);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, List<SalesVendedorEntity>>>
      getSalesByVendedor({String? fechaini, String? fechafin}) async {
    try {
      final result = await salesDatasource.getSalesByVendedor(
          fechaini: fechaini, fechafin: fechafin);
      final resultList = result.map((model) => model.toEntity()).toList();
      return Right(resultList);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }

  @override
  Future<Either<NetworkException, MetaExpoEntity>> getMetaExpo() async {
    try {
      final result = await salesDatasource.getMetaExpo();
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
