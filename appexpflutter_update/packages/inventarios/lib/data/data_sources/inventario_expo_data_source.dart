import 'package:inventarios/data/models/medidas_model.dart';
import 'package:inventarios/data/models/producto_expo_model.dart';

abstract interface class InventarioExpoDataSource {
  Future<List<ProductoExpoModel>> getProductoExpo(Map<String, dynamic> data);
  Future<List<ProductoExpoModel>> getProductoGlobal(Map<String, dynamic> data);

  /// Resuelve una clave de producto (escaneada o tecleada) contra el
  /// endpoint `/productScan/`. Devuelve el primer producto encontrado para
  /// que la búsqueda global pueda autollenar los filtros (calidad, diseño,
  /// largo, ancho). Lanza `NotFoundException` si la clave no existe.
  Future<ProductoExpoModel> getProductoScan(String clave);

  Future<List<MedidasModelInv>> getMedidas();

  /// Lista de calidades (`descripcio`) distintas con existencia > 0.
  /// Se usa para sugerencias "¿quiso decir?" cuando no hay resultados.
  Future<List<String>> getCalidades();
}
