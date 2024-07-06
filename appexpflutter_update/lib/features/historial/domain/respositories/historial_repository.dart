import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HistorialRepository {
  Future<Either<NetworkException, List<HistorialEntity>>> getHistorial(
      String parameter, String endpoint);
}
