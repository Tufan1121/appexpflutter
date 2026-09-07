import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/mixin_products.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sesion_event.dart';
part 'sesion_state.dart';

class DetalleSesionBloc extends Bloc<SesionEvent, SesionState>
    with ProductoSesion {
  final HistorialUsecase historialUsecase;
  List<DetalleSesionEntity> productsSesion = [];
  DetalleSesionBloc({required this.historialUsecase}) : super(SesionInitial()) {
    on<GetDetalleSesionEvent>(_getHistorialDetalleSesion);
    on<AddProductEvent>(
      _addProductToScannedEvent,
      // transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<GetQRProductsEvent>(_getQRProductEvent);
    on<AddSelectedProductsEvent>(_addSelectedProductsEvent);
    on<RemoveProductEvent>(_removeProductEvent);
    on<UpdateProductEvent>(_updateProductEvent);
    on<ClearSesionEvent>((event, emit) => _clearSesionState(emit));
  }

  Future<void> _getQRProductEvent(
      GetQRProductsEvent event, Emitter<SesionState> emit) async {
    emit(SesionLoading());

    final result = await historialUsecase.getProductInfo(event.clave);
    result.fold(
      (failure) => emit(
          SesionError(detalleSesion: productsSesion, message: failure.message)),
      (producto) {
        if (!productsSesion.any((p) => p.producto1 == producto.producto1)) {
          productsSesion.add(convertToDetalleSesionEntity(producto));
        }
        emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
      },
    );
  }

  Future<void> _getHistorialDetalleSesion(
      GetDetalleSesionEvent event, Emitter<SesionState> emit) async {
    emit(SesionLoading());
    final result =
        await historialUsecase.getHistorialDetalleSesion(event.idSesion);

    // Nota: el trabajo asíncrono va FUERA del fold; un callback async dentro
    // de fold no se espera y el emit llegaría con el handler ya cerrado.
    final detalleSesion = result.fold<List<DetalleSesionEntity>?>(
      (failure) {
        emit(SesionError(message: failure.message));
        return null;
      },
      (detalle) => detalle,
    );
    if (detalleSesion == null) return;

    // Al abrir una sesión, la cantidad y el precio deben venir del
    // servidor, no de una selección que quedara de otro pedido.
    UtilsVenta.clearSelecciones();
    productsSesion.addAll(detalleSesion);

    // Restaurar el envío cotizado guardado con la sesión (partida ENVIO del
    // detalle en backend); sin esto el pedido generado desde una sesión
    // recargada salía sin envío.
    UtilsVenta.clearShipping();
    final envioResult = await historialUsecase.getEnvioSesion(event.idSesion);
    envioResult.fold(
      (_) {},
      (envio) {
        if (envio.envio > 0) {
          UtilsVenta.setShipping(
            cost: envio.envio,
            carrier: 'Envío cotizado (sesión)',
            // La observa guardada ya trae servicio y origen/destino; así el
            // pedido que se genere desde la sesión conserva el mismo texto.
            serviceDescription: envio.observa.isNotEmpty
                ? envio.observa
                : 'Envío guardado con la sesión',
          );
        }
      },
    );

    emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
  }

  Future<void> _addSelectedProductsEvent(
      AddSelectedProductsEvent event, Emitter<SesionState> emit) async {
    productsSesion.addAll(event.productos);
    emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
  }

  Future<void> _addProductToScannedEvent(
      AddProductEvent event, Emitter<SesionState> emit) async {
    if (!productsSesion.any((p) => p.producto1 == event.producto.producto1)) {
      productsSesion.add(event.producto);
      emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
    }
  }

  Future<void> _updateProductEvent(
      UpdateProductEvent event, Emitter<SesionState> emit) async {
    final updatedProducts = productsSesion.map((producto) {
      return producto.producto1 == event.producto.producto1
          ? event.producto
          : producto;
    }).toList();
    productsSesion = updatedProducts;
    emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
  }

  Future<void> _removeProductEvent(
      RemoveProductEvent event, Emitter<SesionState> emit) async {
    productsSesion.remove(event.producto);
    UtilsVenta.olvidar(event.producto.producto1);
    if (productsSesion.isEmpty) {
      // Sin productos la lista no se construye, así que el total y el detalle
      // se quedarían con los valores del último producto eliminado.
      UtilsVenta.total = 0;
      UtilsVenta.listProductsOrder.clear();
      UtilsVenta.clearSelecciones();
      emit(SesionInitial());
    } else {
      emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
    }
  }

  void _clearSesionState(Emitter<SesionState> emit) {
    productsSesion.clear();
    UtilsVenta.clearSelecciones();
    // El envío restaurado pertenece a la sesión que se está cerrando.
    UtilsVenta.clearShipping();
    emit(SesionInitial());
  }
}
