import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/galeria_entity.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/medidas_entity.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/producto_inv_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class GaleriaRepository {
  Future<Either<NetworkException, List<GaleriaEntity>>> getgallery(
      {String? descripcion, int? regg});
  Future<Either<NetworkException, List<ProductoGalEntity>>> getgallerypics(
      String descripcion);
  Future<Either<NetworkException, List<MedidasEntity>>> getgalmedidas(
      String descripcion, String diseno);
  Future<Either<NetworkException, List<ProductoInvEntity>>> getgalinventario(
      String descripcion, String diseno);
}
