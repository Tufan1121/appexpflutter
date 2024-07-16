import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_cotiza_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_pedido_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/respositories/historial_repository.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:fpdart/fpdart.dart';

class HistorialUsecase {
  final HistorialRepository historialRepository;

  HistorialUsecase({required this.historialRepository});

  Future<Either<NetworkException, List<HistorialPedidoEntity>>>
      getHistorialPedido(String parameter) async {
    return historialRepository.getHistorialPedido(parameter);
  }

  Future<Either<NetworkException, List<HistorialSesionEntity>>>
      getHistorialSesion(String parameter) async {
    return historialRepository.getHistorialSesion(parameter);
  }

  Future<Either<NetworkException, List<DetalleSesionEntity>>>
      getHistorialDetalleSesion(String idSesion) async {
    return historialRepository.getHistorialDetalleSesion(idSesion);
  }

  Future<Either<NetworkException, List<HistorialCotizaEntity>>>
      getHistorialCotiza(String parameter) async {
    return historialRepository.getHistorialCotiza(parameter);
  }

  Future<Either<NetworkException, ProductoEntity>> getProductInfo(
      String productKey) async {
    return await historialRepository.getProductInfo(productKey);
  }
}
