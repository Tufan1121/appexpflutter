import 'package:fpdart/fpdart.dart';
import 'package:punto_venta/config/exceptions/network_exception.dart';
import 'package:punto_venta/domain/entities/tickets_entity.dart';

abstract interface class TicketsRepository {
  Future<Either<NetworkException, List<TicketsEntity>>> getSalesTickets(
      String fechaInicio, String fechaFin);
}