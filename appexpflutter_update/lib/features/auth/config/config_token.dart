import 'dart:async';
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

  // Verificar y eliminar token si han pasado más de 10 horas, retorna true si expiró
  Future<bool> checkAndDeleteTokenIfNeeded() async {
    final lastCheckedDateTime = await getLastCheckedDateTime();
    final now = DateTime.now();

    if (lastCheckedDateTime == null ||
        now.difference(lastCheckedDateTime).inHours >= 10) {
      await deleteToken();
      await saveLastCheckedDateTime();
      return true; // Indica que el token expiró
    }
    return false; // Indica que el token sigue vigente
  }
}
