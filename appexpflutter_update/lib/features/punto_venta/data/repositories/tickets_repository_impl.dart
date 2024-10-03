import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/consulta/consulta_datasource.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/repositories/tickets_repository.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/tickets_entity.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final ConsultaDatasource ticketsDataSource;

  TicketsRepositoryImpl({required this.ticketsDataSource});
  @override
  Future<Either<NetworkException, List<TicketsEntity>>> getSalesTickets(
      String fechaInicio, String fechaFin) async {
    try {
      final result =
          await ticketsDataSource.getSalesTickets(fechaInicio, fechaFin);
      // Mapear la lista de ProductoModel a ProductoEntity usando toEntity()
      final productosExpoEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(productosExpoEntity);
    } on NotFoundException catch (e) {
      return Left(NetworkException.customMessage(e.message));
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    } catch (e) {
      return Left(
          NetworkException.customMessage('Ocurrió un error inesperado. '));
    }
  }
}
