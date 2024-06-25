import 'package:appexpflutter_update/features/ventas/data/models/cliente_model.dart';

abstract interface class ClienteDataSource {
  Future<List<ClienteModel>> getCliente(String name);
  Future<String> updateClientes(Map<String, dynamic> data);
  Future<bool> createClientes(Map<String, dynamic> data);
}
