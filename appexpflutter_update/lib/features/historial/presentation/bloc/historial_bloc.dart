import 'package:appexpflutter_update/features/historial/domain/entities/historial_cotiza_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_pedido_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'historial_event.dart';
part 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final HistorialUsecase historialUsecase;
  HistorialBloc({required this.historialUsecase}) : super(HistorialInitial()) {
    on<GetHistorialPedido>(_getHistorialPedido);
    on<GetHistorialSesion>(_getHistorialSesion);
    on<GetHistorialCotiza>(_getHistorialCotiza);
    on<ClearHistorialEvent>((event, emit) => _clearHistorialState(emit));
  }

  Future<void> _getHistorialPedido(
      GetHistorialPedido event, Emitter<HistorialState> emit) async {
    emit(HistorialLoading());
    final result = await historialUsecase.getHistorialPedido(event.parameter);
    result.fold(
      (failure) => emit(HistorialError(message: failure.message)),
      (data) => emit(HistorialLoaded(historial: data, search: event.search)),
    );
  }

  Future<void> _getHistorialSesion(
      GetHistorialSesion event, Emitter<HistorialState> emit) async {
    emit(HistorialLoading());
    final result = await historialUsecase.getHistorialSesion(event.parameter);
    result.fold(
      (failure) => emit(HistorialError(message: failure.message)),
      (data) => emit(HistorialSesionLoaded(historial: data, search: event.search)),
    );
  }

  Future<void> _getHistorialCotiza(
      GetHistorialCotiza event, Emitter<HistorialState> emit) async {
    emit(HistorialLoading());
    final result = await historialUsecase.getHistorialCotiza(event.parameter);
    result.fold(
      (failure) => emit(HistorialError(message: failure.message)),
      (data) => emit(HistorialCotizaLoaded(historial: data, search: event.search)),
    );
  }

  void _clearHistorialState(Emitter<HistorialState> emit) {
    emit(HistorialInitial());
  }
}
