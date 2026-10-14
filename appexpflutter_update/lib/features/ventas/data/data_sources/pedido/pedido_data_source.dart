import 'package:appexpflutter_update/features/ventas/data/models/cotiza_model.dart';
import 'package:appexpflutter_update/features/ventas/data/models/pedido_model.dart';
import 'package:appexpflutter_update/features/ventas/data/models/sesion_model.dart';

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
  Future<String> enviarPedidoWhatsapp(
      {required String pedidos,
      int? idExpo,
      String telefono = '',
      String ladaPais = '',
      bool guardar = false});
}

/// El cliente del pedido no tiene teléfono o el que tiene es inválido: la app
/// ofrece capturarlo y reintenta.
class TelefonoClienteException implements Exception {
  final String message;
  const TelefonoClienteException(this.message);

  @override
  String toString() => message;
}
