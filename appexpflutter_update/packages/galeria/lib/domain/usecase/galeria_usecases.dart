import 'package:fpdart/fpdart.dart';
import 'package:galeria/config/exceptions/network_exception.dart';
import 'package:galeria/domain/entities/galeria_entity.dart';
import 'package:galeria/domain/entities/medidas_entity.dart';
import 'package:galeria/domain/entities/producto_entity.dart';
import 'package:galeria/domain/entities/producto_inv_entity.dart';
import 'package:galeria/domain/entities/tabla_precio_entity.dart';
import 'package:galeria/domain/repositories/galeria_repository.dart';

class GaleriaUsecase {
  final GaleriaRepository _galeriaRepository;

  GaleriaUsecase({required GaleriaRepository galeriaRepository})
      : _galeriaRepository = galeriaRepository;

  Future<Either<NetworkException, List<GaleriaEntity>>> getgallery(
      {String? descripcion, int? regg}) async {
    return await _galeriaRepository.getgallery(
        descripcion: descripcion, regg: regg);
  }

  Future<Either<NetworkException, List<ProductoGalEntity>>> getgallerypics(
      String descripcion) async {
    return await _galeriaRepository.getgallerypics(descripcion);
  }

  Future<Either<NetworkException, List<MedidasEntity>>> getgalmedidas(
      String descripcion, String diseno) async {
    return await _galeriaRepository.getgalmedidas(descripcion, diseno);
  }

  Future<Either<NetworkException, List<ProductoInvEntity>>> getgalinventario(
      String descripcion, String diseno) async {
    return await _galeriaRepository.getgalinventario(descripcion, diseno);
  }

  Future<Either<NetworkException, List<TablaPreciosEntity>>> getTablaPrecio(
      String descripcion, String diseno) async {
    return await _galeriaRepository.getTablaPrecio(descripcion, diseno);
  }
}
