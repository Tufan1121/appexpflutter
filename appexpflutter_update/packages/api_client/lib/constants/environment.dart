import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // print('Error loading .env file: $e');
      throw Exception('Error loading .env file: $e');
    }
  }

  static String apiUrl =
      dotenv.env['API_URL'] ?? 'No está configurado el API_URL';
}
