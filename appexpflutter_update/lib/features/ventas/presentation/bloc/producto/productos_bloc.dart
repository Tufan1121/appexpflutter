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
    on<GetQRProductEvent>(_getQRProductEvent);
    on<GetProductEvent>(_getProductEvent
        // transformer: debounce(const Duration(milliseconds: 500)),
        );
    on<StartMultiSelectEvent>(_startMultiSelectEvent);
    on<ToggleProductSelectionEvent>(_toggleProductSelectionEvent);
    on<AddSelectedProductsToScannedEvent>(_addSelectedProductsToScannedEvent);
    on<RemoveProductEvent>(_removeProductEvent);
    on<ClearProductoStateEvent>((event, emit) => _clearProductsState(emit));
    on<ClearProductoIBodegaStateEvent>((event, emit) => _clearProductsIBodegaState(emit));
    on<AddProductToScannedEvent>(
      _addProductToScannedEvent,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<GetIbodegaProductEvent>(_getIbodegaProductEvent);
    // on<SelectRelatedProductEvent>(_selectRelatedProductEvent);
  }

  Future<void> _startMultiSelectEvent(
      StartMultiSelectEvent event, Emitter<ProductosState> emit) async {
    if (state is IbodegaProductosLoaded) {
      emit(IbodegaProductosLoaded(
          productos: (state as IbodegaProductosLoaded).productos,
          selectedProducts: const []));
    }
  }

  Future<void> _toggleProductSelectionEvent(
      ToggleProductSelectionEvent event, Emitter<ProductosState> emit) async {
    if (state is IbodegaProductosLoaded) {
      final currentState = state as IbodegaProductosLoaded;
      final selectedProducts =
          List<ProductoEntity>.from(currentState.selectedProducts);
      if (selectedProducts.contains(event.producto)) {
        selectedProducts.remove(event.producto);
      } else {
        selectedProducts.add(event.producto);
      }
      emit(IbodegaProductosLoaded(
          productos: currentState.productos,
          selectedProducts: selectedProducts));
    }
  }

  Future<void> _addSelectedProductsToScannedEvent(
      AddSelectedProductsToScannedEvent event,
      Emitter<ProductosState> emit) async {
    if (state is IbodegaProductosLoaded) {
      final currentState = state as IbodegaProductosLoaded;
      scannedProducts.addAll(currentState.selectedProducts);
      emit(ProductosLoaded(productos: List.from(scannedProducts)));
    }
  }

  Future<void> _getQRProductEvent(
      GetQRProductEvent event, Emitter<ProductosState> emit) async {
    emit(ProductoLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold(
      (failure) => emit(
          ProductoError(productos: scannedProducts, message: failure.message)),
      (producto) {
        if (!scannedProducts.any((p) => p.producto1 == producto.producto1)) {
          scannedProducts.add(producto);
        }
        emit(ProductosLoaded(productos: List.from(scannedProducts)));
      },
    );
  }

  Future<void> _getProductEvent(
      GetProductEvent event, Emitter<ProductosState> emit) async {
    emit(ProductoLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold(
      (failure) => emit(
          ProductoError(productos: scannedProducts, message: failure.message)),
      (producto) {
        scannedProducts.add(producto);
        emit(ProductosLoaded(productos: List.from(scannedProducts)));
      },
    );
  }

  Future<void> _addProductToScannedEvent(
      AddProductToScannedEvent event, Emitter<ProductosState> emit) async {
    if (!scannedProducts.any((p) => p.producto1 == event.producto.producto1)) {
      scannedProducts.add(event.producto);
      emit(ProductosLoaded(productos: List.from(scannedProducts)));
    }
  }

  Future<void> _getIbodegaProductEvent(
      GetIbodegaProductEvent event, Emitter<ProductosState> emit) async {
    emit(IbodegaProductosLoading());

    final result = await productoUsecase.getIBodegaProducts(event.data);
    result.fold(
      (failure) => emit(
          ProductoError(productos: scannedProducts, message: failure.message)),
      (producto) {
        // scannedProducts.add(producto);
        emit(IbodegaProductosLoaded(productos: producto));
      },
    );
  }

  Future<void> _removeProductEvent(
      RemoveProductEvent event, Emitter<ProductosState> emit) async {
    scannedProducts.remove(event.producto);
    if (scannedProducts.isEmpty) {
      emit(ProductoInitial());
    } else {
      emit(ProductosLoaded(productos: List.from(scannedProducts)));
    }
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  void _clearProductsState(Emitter<ProductosState> emit) {
    scannedProducts.clear();
    emit(ProductoInitial());
  }
  void _clearProductsIBodegaState(Emitter<ProductosState> emit) {
    emit(IbodegaProductosInitial());
  }
}
