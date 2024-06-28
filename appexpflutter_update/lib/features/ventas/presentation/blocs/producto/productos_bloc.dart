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
  Map<String, int> productQuantities = {};
  Map<String, int> productSelectedPrices = {};

  ProductosBloc({required this.productoUsecase}) : super(ProductoInitial()) {
    on<GetQRProductEvent>(_getQRProductEvent);
    on<GetProductEvent>(_getProductEvent
        // transformer: debounce(const Duration(milliseconds: 500)),
        );
    on<AddSelectedProductsToScannedEvent>(_addSelectedProductsToScannedEvent);
    on<RemoveProductEvent>(_removeProductEvent);
    on<ClearProductoStateEvent>((event, emit) => _clearProductsState(emit));

    on<AddProductToScannedEvent>(
      _addProductToScannedEvent,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<UpdateProductEvent>(_updateProductEvent);
    on<UpdateProductQuantityEvent>(_updateProductQuantityEvent);
    on<UpdateProductSelectedPriceEvent>(_updateProductSelectedPriceEvent);
  }

  Future<void> _addSelectedProductsToScannedEvent(
      AddSelectedProductsToScannedEvent event,
      Emitter<ProductosState> emit) async {
    scannedProducts.addAll(event.productos);
    // if (state is IbodegaProductosLoaded) {
    //   final currentState = state as IbodegaProductosLoaded;
    // }
    emit(ProductosLoaded(productos: List.from(scannedProducts)));
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
    productQuantities.clear();
    productSelectedPrices.clear();
    emit(ProductoInitial());
  }

  /// Maneja el evento de actualización de producto en el Bloc.
  Future<void> _updateProductEvent(
      UpdateProductEvent event, Emitter<ProductosState> emit) async {
    // Mapea la lista de productos escaneados y actualiza el producto que coincide con el producto proporcionado en el evento.
    final updatedProducts = scannedProducts.map((producto) {
      // Si el producto en la lista tiene la misma clave (producto1) que el producto en el evento,
      // reemplázalo con el producto del evento. De lo contrario, deja el producto tal como está.
      return producto.producto1 == event.producto.producto1
          ? event.producto
          : producto;
    }).toList();

    // Actualiza la lista de productos escaneados con la lista de productos actualizada.
    scannedProducts = updatedProducts;

    // Emite un nuevo estado con la lista de productos actualizada.
    emit(ProductosLoaded(productos: List.from(scannedProducts)));
  }

  Future<void> _updateProductQuantityEvent(
      UpdateProductQuantityEvent event, Emitter<ProductosState> emit) async {
    productQuantities[event.productoClave] = event.newQuantity;
    emit(ProductosLoaded(productos: List.from(scannedProducts)));
  }

  Future<void> _updateProductSelectedPriceEvent(
      UpdateProductSelectedPriceEvent event,
      Emitter<ProductosState> emit) async {
    productSelectedPrices[event.productoClave] = event.selectedPrice;
    emit(ProductosLoaded(productos: List.from(scannedProducts)));
  }
}
