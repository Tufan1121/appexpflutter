import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inventarios/domain/entities/producto_expo_entity.dart';
import 'package:inventarios/domain/usecases/inventario_expo_usecase.dart';

part 'inventario_expo_event.dart';
part 'inventario_expo_state.dart';

class InventarioExpoBloc
    extends Bloc<InventarioExpoEvent, InventarioExpoState> {
  final InventarioExpoUsecase productoUsecase;
  InventarioExpoBloc({required this.productoUsecase})
      : super(InventarioExpoInitial()) {
    on<GetInventarioProductEvent>(_getIbodegaProductEvent);
    on<ClearInventarioProductoEvent>(
        (event, emit) => _clearProductsIBodegaState(emit));
  }

  Future<void> _getIbodegaProductEvent(GetInventarioProductEvent event,
      Emitter<InventarioExpoState> emit) async {
    emit(InventarioLoading());

    final result = await productoUsecase.getProductoExpo(event.data);
    result.fold(
      (failure) => emit(InventarioError(message: failure.message)),
      (producto) {
        // scannedProducts.add(producto);
        emit(InventarioProductosLoaded(productos: producto));
      },
    );
  }

  void _clearProductsIBodegaState(Emitter<InventarioExpoState> emit) {
    emit(InventarioExpoInitial());
  }
}
