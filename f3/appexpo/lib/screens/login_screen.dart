import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage(); // Instancia de FlutterSecureStorage
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asigna el GlobalKey aquí
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo',
                hintText: 'ejemplo@correo.com',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final uri = Uri.parse('https://tapetestufan.mx:6002/token');
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final Map<String, dynamic> body = {
          'grant_type': '',
          'username': _emailController.text,
          'password': _passwordController.text,
          'scope': '',
          'client_id': '',
          'client_secret': '',
        };

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        if (kDebugMode) {
          print('Token: $token');
        }
        // Aquí deberías guardar el token en algún lugar seguro
        await storage.write(key: 'jwtToken', value: token); // Almacenar el token
        // Mostrar mensaje de éxito
        _showSnackBar("Inicio de sesión exitoso.");

        // Por ejemplo, usando Flutter Secure Storage
        widget.onLoginSuccess(); // Maneja el éxito del inicio de sesión
      } else {
        _showSnackBar("Acceso Denegado.");
        // Manejo de errores, podrías querer mostrar algún mensaje en la interfaz de usuario
        if (kDebugMode) {
          print('Error de inicio de sesión: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      _showSnackBar('Error al conectar al API: $e');
      if (kDebugMode) {
        print('Error al conectar al API: $e');
      }
      // Manejar el error, posiblemente mostrando un mensaje en la interfaz de usuario
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _showSnackBar(String message) {
  final snackBar = SnackBar(content: Text(message));
  // Usa ScaffoldMessenger para compatibilidad con las versiones recientes de Flutter
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
}

