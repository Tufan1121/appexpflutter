import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigToken {
  final storage = const FlutterSecureStorage();

  // Eliminar el token
  Future<void> deleteToken() async {
    await storage.delete(key: 'accessToken');
  }

  // Guardar la última fecha y hora de verificación
  Future<void> saveLastCheckedDateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString('lastCheckedDateTime', now);
  }

  // Obtener la última fecha y hora de verificación
  Future<DateTime?> getLastCheckedDateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckedDateTimeString = prefs.getString('lastCheckedDateTime');
    if (lastCheckedDateTimeString != null) {
      return DateTime.parse(lastCheckedDateTimeString);
    }
    return null;
  }

  // Verificar y eliminar token si es necesario
  Future<void> checkAndDeleteTokenIfNeeded() async {
    final lastCheckedDateTime = await getLastCheckedDateTime();
    final now = DateTime.now();

    // Si han pasado más de 24 horas desde la última verificación
    if (lastCheckedDateTime == null ||
        now.difference(lastCheckedDateTime).inHours >= 24) {
      await deleteToken();
      await saveLastCheckedDateTime();
      // print('Token eliminado porque han pasado más de 24 horas');
    }
  }
}
