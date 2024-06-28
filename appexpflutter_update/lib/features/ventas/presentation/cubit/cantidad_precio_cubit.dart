import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'cantidad_precio_state.dart';


class CantidadCubit extends Cubit<CantidadState> {
  CantidadCubit() : super(const CantidadState(1, 1));

  void incrementar() {
    emit(CantidadState(state.cantidad + 1, state.selectedPrice));
  }

  void decrementar() {
    if (state.cantidad > 1) {
      emit(CantidadState(state.cantidad - 1, state.selectedPrice));
    }
  }

  void seleccionarPrecio(int precio) {
    emit(CantidadState(state.cantidad, precio));
  }
}