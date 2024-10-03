import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/tickets_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/repositories/tickets_repository.dart';
import 'package:fpdart/fpdart.dart';

class TicketsUsecase {
  final TicketsRepository repository;

  TicketsUsecase({required this.repository});

  Future<Either<NetworkException, List<TicketsEntity>>> getTickets(
      String fechaInicio, String fechaFin) async {
    return await repository.getSalesTickets(fechaInicio, fechaFin);
  }
}
