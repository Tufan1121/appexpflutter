import 'package:appexpflutter_update/features/historial/domain/entities/historial_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'historial_event.dart';
part 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final HistorialUsecase historialUsecase;
  HistorialBloc({required this.historialUsecase}) : super(HistorialInitial()) {
    on<GetHistorial>(_getHistorial);
    on<ClearHistorialEvent>((event, emit) => _clearHistorialState(emit));
  }

  Future<void> _getHistorial(
      GetHistorial event, Emitter<HistorialState> emit) async {
    emit(HistorialLoading());
    final result =
        await historialUsecase.getHistorial(event.parameter, event.endpoint);
    result.fold(
      (failure) => emit(HistorialError(message: failure.message)),
      (data) => emit(HistorialLoaded(historial: data, search: event.search)),
    );
  }

  void _clearHistorialState(Emitter<HistorialState> emit) {
    emit(HistorialInitial());
  }
}
