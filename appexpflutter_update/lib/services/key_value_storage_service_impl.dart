import 'package:shared_preferences/shared_preferences.dart';
import 'key_value_storage_service.dart';

class KeyValueStorageServiceImpl extends KeyValueStorageService {
  // Instancia Asíncrona de SharedPreferences:**
  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Obtener Valor Genérico:**
  @override
  Future<T?> getValue<T>(String key) async {
    // 1. Obtener la instancia de SharedPreferences:
    final prefs = await getSharedPrefs();

    // 2. Recuperación Segura de Valores por Tipo:
    switch (T) {
      case const (int):
        return prefs.getInt(key) as T?;
      case const (String):
        return prefs.getString(key) as T?;
      default:
        throw UnimplementedError(
            'GET no implementado para el tipo ${T.runtimeType}');
    }
  }

  // Eliminar Clave:**
  @override
  Future<bool> removeKey(String key) async {
    // 1. Obtener la instancia de SharedPreferences:
    final prefs = await getSharedPrefs();

    // 2. Eliminar el par clave-valor:
    return await prefs.remove(key);
  }

  // Establecer Clave-Valor Genérico:**
  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    // 1. Obtener la instancia de SharedPreferences:
    final prefs = await getSharedPrefs();

    // 2. Almacenamiento Seguro por Tipo:
    switch (T) {
      case const (int):
        prefs.setInt(key, value as int);
        break;
      case const (String):
        prefs.setString(key, value as String);
        break;
      default:
        throw UnimplementedError(
            'Set no implementado para el tipo ${T.runtimeType}');
    }
  }
}
