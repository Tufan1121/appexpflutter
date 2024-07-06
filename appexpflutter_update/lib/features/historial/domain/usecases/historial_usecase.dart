import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/respositories/historial_repository.dart';
import 'package:fpdart/fpdart.dart';

class HistorialUsecase {
  final HistorialRepository historialRepository;

  HistorialUsecase({required this.historialRepository});

  Future<Either<NetworkException, List<HistorialEntity>>> getHistorial(
      String parameter, String endpoint) async {
    return historialRepository.getHistorial(parameter, endpoint);
  }
}
