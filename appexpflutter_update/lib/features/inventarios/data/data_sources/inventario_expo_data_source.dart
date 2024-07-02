import 'package:appexpflutter_update/features/inventarios/data/models/producto_expo_model.dart';

abstract interface class InventarioExpoDataSource {
  Future<List<ProductoExpoModel>> getProductoExpo(Map<String, dynamic> data);
  Future<List<ProductoExpoModel>> getProductoGlobal(Map<String, dynamic> data);
}
