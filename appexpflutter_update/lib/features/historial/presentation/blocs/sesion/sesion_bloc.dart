import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
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

    result.fold(
      (failure) => emit(SesionError(message: failure.message)),
      (detalleSesion) {
        productsSesion.addAll(detalleSesion);
        emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
      },
    );
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
    if (productsSesion.isEmpty) {
      emit(SesionInitial());
    } else {
      emit(SesionLoaded(detalleSesion: List.from(productsSesion)));
    }
  }

  void _clearSesionState(Emitter<SesionState> emit) {
    productsSesion.clear();
    emit(SesionInitial());
  }
}
