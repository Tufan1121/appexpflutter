import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigToken {
  final storage = const FlutterSecureStorage();

// Eliminar el token
  Future<void> deleteToken() async {
    await storage.delete(key: 'accessToken');
  }

// Guardar la última fecha de verificación
  Future<void> saveLastCheckedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('lastCheckedDate', today);
  }

// Obtener la última fecha de verificación
  Future<String?> getLastCheckedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastCheckedDate');
  }

// Verificar y eliminar token si es necesario
  Future<void> checkAndDeleteTokenIfNeeded() async {
    final lastCheckedDate = await getLastCheckedDate();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final now = DateTime.now();

    // Si hoy es lunes y no se ha verificado hoy
    if (now.weekday == DateTime.monday && lastCheckedDate != today) {
      await deleteToken();
      await saveLastCheckedDate();
      print('Token eliminado porque es lunes');
    } else {
      print('Hoy no es lunes o ya se verificó hoy');
    }
  }
}
