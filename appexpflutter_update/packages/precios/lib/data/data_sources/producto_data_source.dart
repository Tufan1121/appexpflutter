
import 'package:precios/data/models/producto_model.dart';

abstract interface class ProductoDataSource {
  Future<ProductoModel> getProductInfo(String productKey);
  Future<List<ProductoModel>> getRelativedProducts(
      String descripcion, String diseno, String producto);
  Future<List<ProductoModel>> getIBodegaProducts(Map<String, dynamic> data);
}
