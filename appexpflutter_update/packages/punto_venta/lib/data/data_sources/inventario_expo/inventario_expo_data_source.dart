import 'package:punto_venta/data/models/producto_expo_model.dart';

abstract interface class InventarioExpoVentaDataSource {
  Future<List<ProductoExpoModel>> getProductosExpo(Map<String, dynamic> data);
  Future<ProductoExpoModel> getProductoExpo(Map<String, dynamic> data);
}
