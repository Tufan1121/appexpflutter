import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/tickets_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class TicketsRepository {
  Future<Either<NetworkException, List<TicketsEntity>>> getSalesTickets(
      String fechaInicio, String fechaFin);
}