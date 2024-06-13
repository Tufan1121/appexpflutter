import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:appexpflutter_update/features/precios/domain/usecases/producto_usecase.dart';

part 'precios_event.dart';
part 'precios_state.dart';

class PreciosBloc extends Bloc<PreciosEvent, PreciosState> {
  final ProductoUsecase productoUsecase;
  PreciosBloc({required this.productoUsecase}) : super(PreciosInitial()) {
    on<GetQRPreciosEvent>(_getQRPreciosEvent);
    on<GetPreciosEvent>(
      _getPreciosEvent,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }

  Future<void> _getQRPreciosEvent(
      GetQRPreciosEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold(
      (failure) => emit(PreciosError(message: failure.message)),
      (data) => emit(PreciosLoaded(producto: data)),
    );
  }

  Future<void> _getPreciosEvent(
      GetPreciosEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    result.fold(
      (failure) => emit(PreciosError(message: failure.message)),
      (data) => emit(PreciosLoaded(producto: data)),
    );
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
