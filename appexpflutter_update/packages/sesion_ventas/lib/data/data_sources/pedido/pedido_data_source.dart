import 'package:sesion_ventas/data/models/cotiza_model.dart';
import 'package:sesion_ventas/data/models/pedido_model.dart';
import 'package:sesion_ventas/data/models/sesion_model.dart';

abstract interface class PedidoDataSource {
  Future<PedidoModel> addPedido(Map<String, dynamic> data);
  Future<String> addDetallePedido(List<Map<String, dynamic>> data);
  Future<SesionModel> addSesionPedido(Map<String, dynamic> data);
  Future<String> addSesionDetallePedido(List<Map<String, dynamic>> data);
  Future<CotizaModel> addCotizaPedido(Map<String, dynamic> data);
  Future<String> addCotizaDetallePedido(List<Map<String, dynamic>> data);
  Future<String> addIdPedido(int idPedido);
  Future<String> addIdCotizaPedido(int idCotiza);
  Future<String> finalSesion(int idSesion);
  
}
