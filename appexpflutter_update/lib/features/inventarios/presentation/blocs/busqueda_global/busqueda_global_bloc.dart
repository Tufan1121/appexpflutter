import 'package:appexpflutter_update/features/inventarios/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/inventarios/domain/usecases/inventario_expo_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'busqueda_global_event.dart';
part 'busqueda_global_state.dart';

class BusquedaGlobalBloc
    extends Bloc<BusquedaGlobalEvent, BusquedaGlobalState> {
  final InventarioExpoUsecase productoUsecase;
  BusquedaGlobalBloc({required this.productoUsecase})
      : super(BusquedaGlobalInitial()) {
    on<GetInventarioProductEvent>(_getIbodegaProductEvent);
    on<ClearInventarioProductoEvent>(
        (event, emit) => _clearProductsIBodegaState(emit));
  }

  Future<void> _getIbodegaProductEvent(GetInventarioProductEvent event,
      Emitter<BusquedaGlobalState> emit) async {
    emit(InventarioLoading());

    final result = await productoUsecase.getProductoGlobal(event.data);
    result.fold(
      (failure) => emit(InventarioError(message: failure.message)),
      (producto) {
        // scannedProducts.add(producto);
        emit(InventarioProductosLoaded(productos: producto));
      },
    );
  }

  void _clearProductsIBodegaState(Emitter<BusquedaGlobalState> emit) {
    emit(BusquedaGlobalInitial());
  }
}
