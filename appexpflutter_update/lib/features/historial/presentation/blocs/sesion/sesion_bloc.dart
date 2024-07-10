import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sesion_event.dart';
part 'sesion_state.dart';

class DetalleSesionBloc extends Bloc<SesionEvent, SesionState> {
  final HistorialUsecase historialUsecase;
  DetalleSesionBloc({required this.historialUsecase}) : super(SesionInitial()) {
    on<GetDetalleSesionEvent>(_getHistorialDetalleSesion);
    on<ClearSesionEvent>((event, emit) => _clearSesionState(emit));
  }

  Future<void> _getHistorialDetalleSesion(
      GetDetalleSesionEvent event, Emitter<SesionState> emit) async {
    emit(SesionLoading());
    final result =
        await historialUsecase.getHistorialDetalleSesion(event.idSesion);

    result.fold(
      (failure) => emit(SesionError(message: failure.message)),
      (detalleSesion) => emit(SesionLoaded(detalleSesion: detalleSesion)),
    );
  }

  void _clearSesionState(Emitter<SesionState> emit) {
    emit(SesionInitial());
  }
}
