import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/usecases/cliente_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteBloc extends Bloc<ClienteEvent, ClienteState> {
  final ClienteUsecase clienteUsecase;
  ClienteBloc({required this.clienteUsecase}) : super(ClienteInitial()) {
    on<GetClientesEvent>(_getClientesEvent,
        transformer: debounce(const Duration(milliseconds: 500)));
  }

  Future<void> _getClientesEvent(
      GetClientesEvent event, Emitter<ClienteState> emit) async {
    emit(ClienteLoading());
    final result = await clienteUsecase.getClientes(event.name);
    result.fold(
      (failure) => emit(ClienteError(message: failure.message)),
      (clientes) => emit(ClienteLoaded(clientes: clientes)),
    );
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }
}
