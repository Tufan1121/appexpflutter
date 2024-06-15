import 'dart:io';

// Clase para ignorar errores de certificado
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Crear una instancia de HttpClient con las configuraciones por defecto
    return super.createHttpClient(context)
      ..badCertificateCallback =
          // Configurar un callback para aceptar todos los certificados, incluso si no son válidos
          (X509Certificate cert, String host, int port) => true;
  }
}
