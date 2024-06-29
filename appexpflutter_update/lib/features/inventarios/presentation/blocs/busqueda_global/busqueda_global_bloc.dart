import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'busqueda_global_event.dart';
part 'busqueda_global_state.dart';

class BusquedaGlobalBloc extends Bloc<BusquedaGlobalEvent, BusquedaGlobalState> {
  BusquedaGlobalBloc() : super(BusquedaGlobalInitial()) {
    on<BusquedaGlobalEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
