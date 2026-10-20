import 'package:appexpflutter_update/features/historial/domain/entities/historial_cotiza_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_pedido_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'historial_event.dart';
part 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final HistorialUsecase historialUsecase;
  HistorialBloc({required this.historialUsecase}) : super(HistorialInitial()) {
    // La búsqueda se lanza mientras se escribe: espera a que se deje de teclear
    // y descarta la respuesta anterior si llega otra (switchMap).
    on<GetHistorialPedido>(_getHistorialPedido, transformer: _debounce());
    on<GetHistorialSesion>(_getHistorialSesion, transformer: _debounce());
    on<GetHistorialCotiza>(_getHistorialCotiza, transformer: _debounce());
    on<ClearHistorialEvent>((event, emit) => _clearHistorialState(emit));
  }

  EventTransformer<T> _debounce<T>() => (events, mapper) => events
      .debounceTime(const Duration(milliseconds: 400))
      .switchMap(mapper);

  /// Búsqueda más reciente de cualquier tipo: si se cambia de pedido a
  /// cotización mientras la de pedido sigue en curso, su respuesta se ignora.
  int _ultimaBusqueda = 0;

  Future<void> _getHistorialPedido(
      GetHistorialPedido event, Emitter<HistorialState> emit) async {
    final busqueda = ++_ultimaBusqueda;
    emit(HistorialLoading());
    final result = await historialUsecase.getHistorialPedido(event.parameter);
    if (busqueda != _ultimaBusqueda) return;
    result.fold(
      (failure) => emit(HistorialError(message: failure.message)),
      (data) => emit(HistorialLoaded(historial: data, search: event.search)),
    );
  }

  Future<void> _getHistorialSesion(
      GetHistorialSesion event, Emitter<HistorialState> emit) async {
    final busqueda = ++_ultimaBusqueda;
    emit(HistorialLoading());
    final result = await historialUsecase.getHistorialSesion(event.parameter);
    if (busqueda != _ultimaBusqueda) return;
    result.fold(
      (failure) => emit(HistorialError(message: failure.message)),
      (data) => emit(HistorialSesionLoaded(historial: data, search: event.search)),
    );
  }

  Future<void> _getHistorialCotiza(
      GetHistorialCotiza event, Emitter<HistorialState> emit) async {
    final busqueda = ++_ultimaBusqueda;
    emit(HistorialLoading());
    final result = await historialUsecase.getHistorialCotiza(event.parameter);
    if (busqueda != _ultimaBusqueda) return;
    result.fold(
      (failure) => emit(HistorialError(message: failure.message)),
      (data) => emit(HistorialCotizaLoaded(historial: data, search: event.search)),
    );
  }

  void _clearHistorialState(Emitter<HistorialState> emit) {
    _ultimaBusqueda++; // una búsqueda en curso ya no debe llenar la lista
    emit(HistorialInitial());
  }
}
