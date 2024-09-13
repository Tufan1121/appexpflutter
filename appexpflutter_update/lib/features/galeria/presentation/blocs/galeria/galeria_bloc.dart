import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:galeria/domain/entities/galeria_entity.dart';
import 'package:galeria/domain/usecase/galeria_usecases.dart';

part 'galeria_event.dart';
part 'galeria_state.dart';

class GaleriaBloc extends Bloc<GaleriaEvent, GaleriaState> {
  final GaleriaUsecase galeriaUsecases;
  List<GaleriaEntity> _loadedGaleria =
      []; // Lista para acumular los elementos cargados
  bool isSearching = false; // Indicador de búsqueda activa

  GaleriaBloc({required this.galeriaUsecases}) : super(GaleriaInitial()) {
    on<GetGaleriaEvent>(_getGaleriaEvent);
    on<ResetGaleriaEvent>((event, emit) {
      _loadedGaleria.clear(); // Limpiar la lista al resetear
      isSearching = false; // Reiniciar el estado de búsqueda
      emit(GaleriaInitial());
    });
  }

  Future<void> _getGaleriaEvent(
      GetGaleriaEvent event, Emitter<GaleriaState> emit) async {
    if (event.descripcion != null && event.descripcion!.isNotEmpty) {
      // Si se ha proporcionado una descripción, se trata de una búsqueda
      isSearching = true;
      _loadedGaleria
          .clear(); // Limpiar la lista para nuevos resultados de búsqueda
    } else if (!isSearching && _loadedGaleria.isEmpty) {
      // Si no es búsqueda y es la primera carga, mostrar un indicador de carga
      emit(GaleriaLoading());
    }

    final result = await galeriaUsecases.getgallery(
        descripcion: event.descripcion ?? '', regg: event.regg);

    result.fold(
      (failure) => emit(GaleriaError(message: failure.message)),
      (galeria) {
        if (isSearching) {
          // Si es una búsqueda, reemplazar los datos
          _loadedGaleria = galeria;
        } else {
          // Si es una carga adicional, acumular los nuevos datos sin limpiar la lista existente
          _loadedGaleria.addAll(galeria);
        }
        emit(GaleriaLoaded(galeria: List.from(_loadedGaleria)));
      },
    );
  }
}
