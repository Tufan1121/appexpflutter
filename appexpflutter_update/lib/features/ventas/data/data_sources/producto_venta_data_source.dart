

import 'package:appexpflutter_update/features/precios/data/models/producto_model.dart';

abstract interface class ProductoVentaDataSource {
  Future<ProductoModel> getProductInfo(String productKey);
  Future<List<ProductoModel>> getIBodegaProducts(Map<String, dynamic> data);
}
