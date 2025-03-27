import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:galeria/domain/entities/producto_con_medidas.dart';
import 'package:galeria/domain/entities/producto_entity.dart';
import 'package:galeria/domain/usecase/galeria_usecases.dart';

part 'detalle_galeria_event.dart';
part 'detalle_galeria_state.dart';

class DetalleGaleriaBloc
    extends Bloc<DetalleGaleriaEvent, DetalleGaleriaState> {
  final GaleriaUsecase galeriaUsecases;
  DetalleGaleriaBloc({required this.galeriaUsecases})
      : super(DetalleGaleriaInitial()) {
    on<GetProductEvent>(_getDetalleGaleriaEvent);
    on<ResetDetalleGaleriaEvent>((event, emit) {
      emit(DetalleGaleriaInitial());
    });
  }

  Future<void> _getDetalleGaleriaEvent(
      GetProductEvent event, Emitter<DetalleGaleriaState> emit) async {
    // Emite el estado de carga antes de empezar a procesar
    emit(DetalleGaleriaLoading());

    final result = await galeriaUsecases.getgallerypics(event.descripcion);
    await result.fold(
      (failure) async => emit(DetalleGaleriaError(message: failure.message)),
      (producto) async {
        List<ProductoConMedidas> productosConMedidas = [];

        // Procesar cada producto de manera asíncrona
        for (var i = 0; i < producto.length; i++) {
          final medidasResult = await galeriaUsecases.getgalmedidas(
              producto[i].descripcio, producto[i].diseno);

          medidasResult.fold((failure) {
            // Emitir un error si falla la obtención de medidas
            emit(DetalleGaleriaError(message: failure.message));
          }, (medidas) {
            // Agrega el producto con sus medidas a la lista
            productosConMedidas.add(
                ProductoConMedidas(producto: producto[i], medidas: medidas));
          });
        }

        // las operaciones asíncronas han finalizado antes de emitir el estado final
        if (!emit.isDone) {
          emit(DetalleGaleriaLoaded(productosConMedidas: productosConMedidas));
        }
      },
    );
  }
}
