import 'package:appexpflutter_update/features/punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/inventario_expo_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'inventario_tienda_event.dart';
part 'inventario_tienda_state.dart';

class InventarioTiendaBloc
    extends Bloc<InventarioTiendaEvent, InventarioTiendaState> {
  final InventarioExpoVentaUsecase productoUsecase;
  InventarioTiendaBloc({required this.productoUsecase})
      : super(InventarioTiendaInitial()) {
    on<StartMultiSelectEvent>(_startMultiSelectEvent);
    on<ToggleProductSelectionEvent>(_toggleProductSelectionEvent);
    on<GetInventarioProductEvent>(_getIbodegaProductEvent);
    on<ClearInventarioProductoEvent>(
        (event, emit) => _clearProductsIBodegaState(emit));
  }

  Future<void> _getIbodegaProductEvent(GetInventarioProductEvent event,
      Emitter<InventarioTiendaState> emit) async {
    emit(InventarioLoading());

    final result = await productoUsecase.getProductosExpo(event.data);
    result.fold(
      (failure) => emit(InventarioError(message: failure.message)),
      (producto) {
        // scannedProducts.add(producto);
        emit(InventarioProductosLoaded(productos: producto));
      },
    );
  }

  Future<void> _startMultiSelectEvent(
      StartMultiSelectEvent event, Emitter<InventarioTiendaState> emit) async {
    if (state is InventarioProductosLoaded) {
      emit(InventarioProductosLoaded(
          productos: (state as InventarioProductosLoaded).productos,
          selectedProducts: const []));
    }
  }

  Future<void> _toggleProductSelectionEvent(ToggleProductSelectionEvent event,
      Emitter<InventarioTiendaState> emit) async {
    if (state is InventarioProductosLoaded) {
      final currentState = state as InventarioProductosLoaded;
      final selectedProducts =
          List<ProductoExpoEntity>.from(currentState.selectedProducts);
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

  void _clearProductsIBodegaState(Emitter<InventarioTiendaState> emit) {
    emit(InventarioTiendaInitial());
  }
}
