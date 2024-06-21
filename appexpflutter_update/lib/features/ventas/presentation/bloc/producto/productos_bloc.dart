// productos_bloc.dart

import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/precios/domain/usecases/producto_usecase.dart';

part 'productos_event.dart';
part 'productos_state.dart';

class ProductosBloc extends Bloc<ProductosEvent, ProductosState> {
  final ProductoUsecase productoUsecase;
  List<ProductoEntity> scannedProducts = [];
  
  ProductosBloc({required this.productoUsecase}) : super(ProductoInitial()) {
    on<GetQRProductEvent>(_getQRPreciosEvent);
    on<GetProductEvent>(
      _getPreciosEvent,
      // transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<RemoveProductEvent>(_removeProductEvent);
    on<ClearProductoStateEvent>((event, emit) => _clearPreciosState(emit));
    // on<GetRelativedProductsEvent>(_getRelativedProductsEvent);
    // on<SelectRelatedProductEvent>(_selectRelatedProductEvent);
  }

  Future<void> _getQRPreciosEvent(
      GetQRProductEvent event, Emitter<ProductosState> emit) async {
    emit(ProductoLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold(
      (failure) => emit(ProductoError(productos:scannedProducts, message:failure.message)),
      (producto) {
        if (!scannedProducts.any((p) => p.producto1 == producto.producto1)) {
          scannedProducts.add(producto);
        }
        emit(ProductosLoaded(productos:List.from(scannedProducts)));
      },
    );
  }

  Future<void> _getPreciosEvent(
      GetProductEvent event, Emitter<ProductosState> emit) async {
    emit(ProductoLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold(
      (failure) => emit(ProductoError(productos: scannedProducts, message:failure.message)),
      (producto) {
        scannedProducts.add(producto);
        emit(ProductosLoaded(productos :List.from(scannedProducts)));
      },
    );
  }

  Future<void> _removeProductEvent(
      RemoveProductEvent event, Emitter<ProductosState> emit) async {
    scannedProducts.remove(event.producto);
    if (scannedProducts.isEmpty) {
      emit(ProductoInitial());
    } else {
      emit(ProductosLoaded(productos:List.from(scannedProducts)));
    }
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  void _clearPreciosState(Emitter<ProductosState> emit) {
    scannedProducts.clear();
    emit(ProductoInitial());
  }
}
