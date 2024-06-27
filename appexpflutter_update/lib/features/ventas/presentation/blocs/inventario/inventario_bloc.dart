import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/precios/domain/usecases/producto_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'inventario_event.dart';
part 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  final ProductoUsecase productoUsecase;
  InventarioBloc({required this.productoUsecase}) : super(InventarioInitial()) {
    on<StartMultiSelectEvent>(_startMultiSelectEvent);
    on<ToggleProductSelectionEvent>(_toggleProductSelectionEvent);
    on<GetInventarioProductEvent>(_getIbodegaProductEvent);
    on<ClearInventarioProductoEvent>(
        (event, emit) => _clearProductsIBodegaState(emit));
  }

  Future<void> _getIbodegaProductEvent(
      GetInventarioProductEvent event, Emitter<InventarioState> emit) async {
    emit(InventarioLoading());

    final result = await productoUsecase.getIBodegaProducts(event.data);
    result.fold(
      (failure) => emit(
          InventarioError(message: failure.message)),
      (producto) {
        // scannedProducts.add(producto);
        emit(InventarioProductosLoaded(productos: producto));
      },
    );
  }

  Future<void> _startMultiSelectEvent(
      StartMultiSelectEvent event, Emitter<InventarioState> emit) async {
    if (state is InventarioProductosLoaded) {
      emit(InventarioProductosLoaded(
          productos: (state as InventarioProductosLoaded).productos,
          selectedProducts: const []));
    }
  }

  Future<void> _toggleProductSelectionEvent(
      ToggleProductSelectionEvent event, Emitter<InventarioState> emit) async {
    if (state is InventarioProductosLoaded) {
      final currentState = state as InventarioProductosLoaded;
      final selectedProducts =
          List<ProductoEntity>.from(currentState.selectedProducts);
      if (selectedProducts.contains(event.producto)) {
        selectedProducts.remove(event.producto);
      } else {
        selectedProducts.add(event.producto);
      }
      emit(InventarioProductosLoaded(
          productos: currentState.productos,
          selectedProducts: selectedProducts));
    }
  }

  void _clearProductsIBodegaState(Emitter<InventarioState> emit) {
    emit(InventarioInitial());
  }
}
