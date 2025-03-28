import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_cotiza_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_pedido_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/producto_entity.dart';

import 'package:fpdart/fpdart.dart';

abstract interface class HistorialRepository {
  Future<Either<NetworkException, List<HistorialPedidoEntity>>>
      getHistorialPedido(String parameter);
  Future<Either<NetworkException, List<HistorialSesionEntity>>>
      getHistorialSesion(String parameter);
  Future<Either<NetworkException, List<DetalleSesionEntity>>>
      getHistorialDetalleSesion(String idSesion);
  Future<Either<NetworkException, List<HistorialCotizaEntity>>>
      getHistorialCotiza(String parameter);

  Future<Either<NetworkException, ProductoEntity>> getProductInfo(
      String productKey);
}
