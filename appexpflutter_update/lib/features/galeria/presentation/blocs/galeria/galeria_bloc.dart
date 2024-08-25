import 'package:appexpflutter_update/features/galeria/domain/entities/galeria_entity.dart';
import 'package:appexpflutter_update/features/galeria/domain/usecase/galeria_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'galeria_event.dart';
part 'galeria_state.dart';

class GaleriaBloc extends Bloc<GaleriaEvent, GaleriaState> {
  final GaleriaUsecase galeriaUsecases;
  GaleriaBloc({required this.galeriaUsecases}) : super(GaleriaInitial()) {
    on<GetGaleriaEvent>(_getGaleriaEvent);
    on<ResetGaleriaEvent>((event, emit) {
      emit(GaleriaInitial());
    });
  }

  Future<void> _getGaleriaEvent(
      GetGaleriaEvent event, Emitter<GaleriaState> emit) async {
    emit(GaleriaLoading());

    final result = await galeriaUsecases.getgallery(
        descripcion: event.descripcion ?? '', regg: event.regg ?? 5);
    result.fold(
      (failure) => emit(GaleriaError(message: failure.message)),
      (galeria) {
        emit(GaleriaLoaded(galeria: galeria));
      },
    );
  }
}
