import 'package:appexpflutter_update/features/punto_venta/data/models/pedido_model.dart';

abstract interface class PedidoDataVentaSource {
  Future<PedidoModel> addPedido(Map<String, dynamic> data);
  Future<String> addDetallePedido(List<Map<String, dynamic>> data);
}
