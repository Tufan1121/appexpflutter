import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/respositories/historial_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialDataSource historialDataSource;

  HistorialRepositoryImpl({required this.historialDataSource});
  @override
  Future<Either<NetworkException, List<HistorialEntity>>> getHistorial(
      String parameter, String endpoint) async {
    try {
      final result =
          await historialDataSource.getHistorial(parameter, endpoint);
      final historialListEntity =
          result.map((model) => model.toEntity()).toList();
      return Right(historialListEntity);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
