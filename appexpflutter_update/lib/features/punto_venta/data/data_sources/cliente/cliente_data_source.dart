import 'package:appexpflutter_update/features/punto_venta/data/models/cliente_model.dart';

abstract interface class ClienteDataVentaSource {
  Future<List<ClienteModel>> getCliente(String name);
  Future<String> updateClientes(Map<String, dynamic> data);
  Future<String> createClientes(Map<String, dynamic> data);
}
