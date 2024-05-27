// ignore: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

bool _requiereFactura = false; // Esta variable manejará el estado del Switch

class NewCustomerScreen extends StatefulWidget {
  const NewCustomerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewCustomerScreenState createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  bool _factura = false;
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _regimenController = TextEditingController();
  final TextEditingController _cpFacturaController = TextEditingController();
Future<void> _submitForm() async {
  final String token = await _storage.read(key: 'jwtToken') ?? '';
  final String nombre = Uri.encodeComponent(_nombreController.text);
  final String apellido = Uri.encodeComponent(_apellidoController.text);
  final String telefono = Uri.encodeComponent(_telefonoController.text);
  final String correo = Uri.encodeComponent(_correoController.text);
  final String factura = _requiereFactura ? '1' : '0';
  final String direccion = Uri.encodeComponent(_direccionController.text);
  final String cp = Uri.encodeComponent(_cpController.text);

  // Construir la URL con parámetros de consulta
  final String queryParams = 'nombre=$nombre&apellido=$apellido&telefono=$telefono&correo=$correo&factura=$factura&direccion=$direccion&cp=$cp';
  final Uri url = Uri.parse('https://tapetestufan.mx:6002/insertClientesExpo?$queryParams');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      // Si tu endpoint realmente espera un cuerpo vacío, puedes omitir el `body` o enviar un JSON vacío.
      //body: jsonEncode({}),
    );

    if (response.statusCode == 200) {

      // Justo después de verificar que la respuesta es exitosa
      //var decodedResponse = {response.body};
      //var idCliente = decodedResponse['id_cliente']; // Asegúrate de que este sea el campo correcto
      // Ahora, puedes guardar el idCliente donde necesites. Por ejemplo, en FlutterSecureStorage:
      //await _storage.write(key: 'id_cliente', value: idCliente.toString());
      //print("idCliente");
      //await _storage.write(key: 'id_cliente', value: decodedResponse);
      // Decodifica la respuesta
      final decodedResponse = json.decode(response.body);


 // Asegúrate de que decodedResponse es un Map antes de intentar acceder a 'id_cliente'
  if (decodedResponse is Map<String, dynamic>) {
    final idCliente = decodedResponse['id_cliente'].toString();

    // Guarda el id del cliente en FlutterSecureStorage
    await _storage.write(key: 'id_cliente', value: idCliente);

    // Muestra un mensaje o realiza una acción después de guardar con éxito
    if (kDebugMode) {
      print('ID del cliente guardado con éxito: $idCliente');
    }
  } else {
    // Maneja el caso en que la respuesta no sea un Map como esperabas
    if (kDebugMode) {
      print('La respuesta no tiene el formato esperado');
    }
  }
    } else {
      if (kDebugMode) {
        print('Error al agregar cliente: ${response.body}');
      }
      _showSnackBar('Error al agregar cliente');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error al enviar el formulario: $e');
    }
    _showSnackBar('Error al enviar el formulario');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                keyboardType: TextInputType.name, // Teclado especial para nombres
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _apellidoController,
                 decoration: const InputDecoration(labelText: 'Apellido'),
                 keyboardType: TextInputType.name, // Teclado especial para nombres
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el apellido';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono/WhatsApp'),
                keyboardType: TextInputType.phone, // Teclado numérico especial para teléfono
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el numero';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress, // Teclado especial para correo electrónico
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el correo';
                  }
                  return null;
                },
              ),

              SwitchListTile(
                title: Text(_factura ? 'Requiere Factura: Sí' : 'Requiere Factura: No'),
                value: _factura, // El valor actual del interruptor
                onChanged: (bool value) { // Se llama cada vez que el interruptor cambia
                setState(() {
                   _factura = value; // Actualiza el estado del interruptor
                 });
                 },
              ),

              if (_requiereFactura) ...[ // Si requiere factura, muestra estos campos
                TextFormField(
                  controller: _rfcController,
                  decoration: const InputDecoration(labelText: 'RFC'),
                  // Añade validator si lo necesitas
                ),
                TextFormField(
                  controller: _empresaController,
                  decoration: const InputDecoration(labelText: 'Empresa'),
                  // Añade validator si lo necesitas
                ),
                TextFormField(
                  controller: _regimenController,
                  decoration: const InputDecoration(labelText: 'Régimen'),
                  // Añade validator si lo necesitas
                ),
                TextFormField(
                  controller: _cpFacturaController,
                  decoration: const InputDecoration(labelText: 'CP'),
                  // Añade validator si lo necesitas
                ),
              ],

              // Repite para los demás campos...
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showSnackBar(String message) {
  final snackBar = SnackBar(content: Text(message));
  // Usa ScaffoldMessenger para compatibilidad con las versiones recientes de Flutter
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
}
