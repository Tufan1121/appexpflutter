import 'package:rxdart/rxdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:precios/domain/entities/producto_entity.dart';
import 'package:precios/domain/usecases/producto_usecase.dart';


part 'precios_event.dart';
part 'precios_state.dart';

class PreciosBloc extends Bloc<PreciosEvent, PreciosState> {
  final ProductoUsecase productoUsecase;
  PreciosBloc({required this.productoUsecase}) : super(PreciosInitial()) {
    on<GetQRProductEvent>(_getQRPreciosEvent);
    on<GetProductEvent>(
      _getPreciosEvent,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<GetRelativedProductsEvent>(_getRelativedProductsEvent);
    on<SelectRelatedProductEvent>(_selectRelatedProductEvent);
    on<ClearPreciosStateEvent>((event, emit) => _clearPreciosState(emit));
  }

  Future<void> _getQRPreciosEvent(
      GetQRProductEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold((failure) => emit(PreciosError(message: failure.message)),
        (producto) {
      emit(PreciosLoaded(producto: producto));
    });
  }

  Future<void> _getPreciosEvent(
      GetProductEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold((failure) => emit(PreciosError(message: failure.message)),
        (producto) => emit(PreciosLoaded(producto: producto)));
  }

  Future<void> _getRelativedProductsEvent(
      GetRelativedProductsEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getRelativedProducts(
      event.producto.descripcio,
      event.producto.diseno,
      event.producto.producto,
    );

    result.fold(
        (failure) => emit(PreciosError(message: failure.message)),
        (data) => emit(
            PreciosRelativosLoaded(producto: event.producto, productos: data)));
  }

  Future<void> _selectRelatedProductEvent(
      SelectRelatedProductEvent event, Emitter<PreciosState> emit) async {
    // Verifica si el estado actual es PreciosLoaded
    if (state is PreciosRelativosLoaded) {
      // Extrae el estado actual como PreciosLoaded
      final currentState = state as PreciosRelativosLoaded;

      // Emite un nuevo estado PreciosLoaded con el producto seleccionado actualizado
      emit(PreciosRelativosLoaded(
          producto: event.selectedProduct, productos: currentState.productos));
    }
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

void _clearPreciosState(Emitter<PreciosState> emit) {
    emit(PreciosInitial());
  }
}
