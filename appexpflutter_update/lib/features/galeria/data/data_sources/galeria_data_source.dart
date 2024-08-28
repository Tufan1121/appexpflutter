import 'package:appexpflutter_update/features/galeria/data/model/galeria_model.dart';
import 'package:appexpflutter_update/features/galeria/data/model/medidas_model.dart';
import 'package:appexpflutter_update/features/galeria/data/model/producto_inv_model.dart';
import 'package:appexpflutter_update/features/galeria/data/model/producto_model.dart';
import 'package:appexpflutter_update/features/galeria/data/model/tabla_precio_model.dart';

abstract interface class GaleriaDataSource {
  Future<List<GaleriaModel>> getgallery({String? descripcion, int? regg});
  Future<List<ProductoModel>> getgallerypics(String descripcion);
  Future<List<MedidasModel>> getgalmedidas(String descripcion, String diseno);
  Future<List<TablaPrecioModel>> getTablaPrecio(String descripcion, String diseno);
  Future<List<ProductoInvModel>> getgalinventario(
      String descripcion, String diseno);
}
