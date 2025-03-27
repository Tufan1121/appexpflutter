import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:precios/domain/entities/producto_entity.dart';
import 'package:precios/domain/usecases/producto_usecase.dart';

part 'inventario_bodega_event.dart';
part 'inventario_bodega_state.dart';

class InventarioBodegaBloc
    extends Bloc<InventarioEvent, InventarioBodegaState> {
  final ProductoUsecase productoUsecase;
  InventarioBodegaBloc({required this.productoUsecase})
      : super(InventarioInitial()) {
    on<GetInventarioProductEvent>(_getIbodegaProductEvent);
    on<ClearInventarioProductoEvent>(
        (event, emit) => _clearProductsIBodegaState(emit));
  }

  Future<void> _getIbodegaProductEvent(GetInventarioProductEvent event,
      Emitter<InventarioBodegaState> emit) async {
    emit(InventarioLoading());

    final result = await productoUsecase.getIBodegaProducts(event.data);
    result.fold(
      (failure) => emit(InventarioError(message: failure.message)),
      (producto) {
        // scannedProducts.add(producto);
        emit(InventarioProductosLoaded(productos: producto));
      },
    );
  }

  void _clearProductsIBodegaState(Emitter<InventarioBodegaState> emit) {
    emit(InventarioInitial());
  }
}
