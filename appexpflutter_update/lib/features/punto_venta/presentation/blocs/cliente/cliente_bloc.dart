import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/cliente_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/cliente_usecase.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteVentaBloc extends Bloc<ClienteEvent, ClienteState> {
  final ClienteVentaUsecase clienteUsecase;
  ClienteVentaBloc({required this.clienteUsecase}) : super(ClienteInitial()) {
    on<GetClientesEvent>(_getClientesEvent,
        transformer: debounce(const Duration(milliseconds: 500)));
    on<CreateClientesEvent>(_createClienteEvent);
    on<UpdateClientesEvent>(_updateClientesEvent);
    on<ClearClienteStateEvent>((event, emit) => _clearClienteState(emit));
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

  Future<void> _createClienteEvent(
      CreateClientesEvent event, Emitter<ClienteState> emit) async {
    final result = await clienteUsecase.createsClientes(event.data);
    result.fold(
      (failure) => emit(ClienteError(message: failure.message)),
      (idCliente) {
        emit(ClienteSave(idCliente: int.parse(idCliente)));
      },
    );
  }

  Future<void> _updateClientesEvent(
      UpdateClientesEvent event, Emitter<ClienteState> emit) async {
    if (state is ClienteLoaded) {
      // Haz un casting del estado actual a ClienteLoaded
      final currentState = state as ClienteLoaded;

      // Crea una nueva lista de clientes basada en la lista actual
      final updatedClientes = List<ClienteEntity>.from(currentState.clientes);

      // Encuentra el índice del cliente que necesita ser actualizado
      final index = updatedClientes.indexWhere(
          (cliente) => cliente.idCliente == event.data['id_cliente']);

      // Si el cliente es encontrado en la lista
      if (index != -1) {
        // Crea una nueva instancia de ClienteEntity con los datos actualizados
        final updatedCliente = ClienteEntity(
          idCliente: updatedClientes[index].idCliente,
          nombre: event.data['nombre'],
          apellido: event.data['apellido'],
          telefono: event.data['telefono'],
          correo: event.data['correo'],
          factura: event.data['factura'],
        );

        // Reemplaza la instancia antigua con la nueva en la lista de clientes
        updatedClientes[index] = updatedCliente;
      }

      final result = await clienteUsecase.updateClientes(event.data);
      result.fold(
        (failure) => emit(ClienteError(message: failure.message)),
        (success) {
          emit(ClienteLoaded(clientes: updatedClientes, message: success));
        },
      );
    }
  }

  void _clearClienteState(Emitter<ClienteState> emit) {
    emit(ClienteInitial());
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }
}
