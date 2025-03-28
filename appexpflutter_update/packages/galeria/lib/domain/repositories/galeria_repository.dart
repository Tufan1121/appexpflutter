import 'package:fpdart/fpdart.dart';
import 'package:galeria/config/exceptions/network_exception.dart';
import 'package:galeria/domain/entities/galeria_entity.dart';
import 'package:galeria/domain/entities/medidas_entity.dart';
import 'package:galeria/domain/entities/producto_entity.dart';
import 'package:galeria/domain/entities/producto_inv_entity.dart';
import 'package:galeria/domain/entities/tabla_precio_entity.dart';

abstract interface class GaleriaRepository {
  Future<Either<NetworkException, List<GaleriaEntity>>> getgallery(
      {String? descripcion, int? regg});
  Future<Either<NetworkException, List<ProductoGalEntity>>> getgallerypics(
      String descripcion);
  Future<Either<NetworkException, List<MedidasEntity>>> getgalmedidas(
      String descripcion, String diseno);
  Future<Either<NetworkException, List<TablaPreciosEntity>>> getTablaPrecio(
      String descripcion, String diseno);
  Future<Either<NetworkException, List<ProductoInvEntity>>> getgalinventario(
      String descripcion, String diseno);
}
