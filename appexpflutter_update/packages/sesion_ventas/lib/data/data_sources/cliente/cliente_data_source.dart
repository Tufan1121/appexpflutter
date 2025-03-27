
import 'package:sesion_ventas/data/models/cliente_model.dart';

abstract interface class ClienteDataSource {
  Future<List<ClienteModel>> getCliente(String name);
  Future<String> updateClientes(Map<String, dynamic> data);
  Future<String> createClientes(Map<String, dynamic> data);
}
