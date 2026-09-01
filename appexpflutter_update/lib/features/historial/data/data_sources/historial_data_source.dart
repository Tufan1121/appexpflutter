import 'package:appexpflutter_update/features/historial/data/models/detalle_sesion_model.dart';
import 'package:appexpflutter_update/features/historial/data/models/historial_cotiza_model.dart';
import 'package:appexpflutter_update/features/historial/data/models/historial_pedido_model.dart';
import 'package:appexpflutter_update/features/historial/data/models/historial_sesion_model.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';

abstract interface class HistorialDataSource {
  Future<List<HistorialPedidoModel>> getHistorialPedido(String parameter);
  Future<List<HistorialSesionModel>> getHistorialSesion(String parameter);
  Future<List<DetalleSesionModel>> getHistorialDetalleSesion(String idSesion);

  /// Envío cotizado guardado con la sesión (0 si no tiene).
  Future<double> getEnvioSesion(String idSesion);
  Future<List<HistorialCotizaModel>> getHistorialCotiza(String parameter);

  Future<ProductoEntity> getProductInfo(
      String productKey);
}
