import 'package:appexpflutter_update/features/ventas/data/models/pedido_model.dart';

abstract interface class PedidoDataSource {
  Future<PedidoModel> addPedido(Map<String, dynamic> data);
  Future<String> addDetallePedido(List<Map<String, dynamic>> data);
  Future<PedidoModel> addSesionPedido(Map<String, dynamic> data);
  Future<String> addSesionDetallePedido(List<Map<String, dynamic>> data);
  Future<String> addIdPedido(int idPedido);
}
