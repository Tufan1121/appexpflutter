import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    try {
      await dotenv.load(fileName: 'assets/env');
    } catch (e) {
      // print('Error loading .env file: $e');
      throw Exception('Error loading .env file: $e');
    }
  }

  static String apiUrl =
      dotenv.env['API_URL'] ?? 'No está configurado el API_URL';

  /// URL de respaldo (ej. túnel AWS). Si la principal falla por conexión,
  /// el DioClient cambia a esta automáticamente.
  static String apiUrl2 = dotenv.env['API_URL_2'] ?? '';

  static String enviaToken =
      dotenv.env['TOKEN'] ?? '';

  /// URLs disponibles: principal + respaldo (si está configurado y es distinto).
  static List<String> get apiUrls {
    final list = <String>[apiUrl];
    if (apiUrl2.isNotEmpty && apiUrl2 != apiUrl) list.add(apiUrl2);
    return list;
  }

  /// Hay más de una URL para hacer failover.
  static bool get hasFallback => apiUrls.length > 1;

  /// Índice de la URL que está funcionando; se recuerda entre peticiones para
  /// que, una vez que una cae, las siguientes empiecen por la que sí responde.
  static int activeIndex = 0;

  /// URL activa actual.
  static String get activeApiUrl {
    final list = apiUrls;
    return list[activeIndex % list.length];
  }
}
