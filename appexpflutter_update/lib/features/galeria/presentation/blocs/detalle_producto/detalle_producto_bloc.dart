import 'package:appexpflutter_update/features/galeria/domain/entities/producto_con_existencias.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/galeria/domain/usecase/galeria_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'detalle_producto_event.dart';
part 'detalle_producto_state.dart';

class DetalleProductoBloc
    extends Bloc<DetalleProductoEvent, DetalleProductoState> {
  final GaleriaUsecase galeriaUsecases;
  DetalleProductoBloc({required this.galeriaUsecases})
      : super(DetalleProductoInitial()) {
    on<GetProductsEvent>(_getDetalleProductoEvent);
    on<ResetDetalleProductoEvent>((event, emit) {
      emit(DetalleProductoInitial());
    });
  }

  Future<void> _getDetalleProductoEvent(
      GetProductsEvent event, Emitter<DetalleProductoState> emit) async {
    // Emite el estado de carga antes de empezar a procesar
    emit(DetalleProductoLoading());

    final result = await galeriaUsecases.getgalinventario(
        event.producto.descripcio, event.producto.diseno);
    result.fold(
      (failure) async {
        emit(DetalleProductoError(message: failure.message));
      },
      (producto) async {
        // las operaciones asíncronas han finalizado antes de emitir el estado final
        final productosConExistencias = ProductoConExistencias(
            producto: event.producto, existencias: producto);
        if (!emit.isDone) {
          emit(DetalleProductoLoaded(
              productosConExistencias: productosConExistencias));
        }
      },
    );
  }
}
