abstract interface class PedidoDataSource {
  Future<int> addPedido(Map<String, dynamic> data);
  Future< String> addDetallePedido(Map<String, dynamic> data);
}