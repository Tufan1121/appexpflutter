part of 'cliente_bloc.dart';

sealed class ClienteEvent extends Equatable {
  const ClienteEvent();

  @override
  List<Object> get props => [];
}

class GetClientesEvent extends ClienteEvent {
  final String name;

  const GetClientesEvent({required this.name});
  @override
  List<Object> get props => [name];
}

class UpdateClientesEvent extends ClienteEvent {
  final Map<String, dynamic> data;

  const UpdateClientesEvent({required this.data});
  @override
  List<Object> get props => [data];
}
class CreateClientesEvent extends ClienteEvent {
  final Map<String, dynamic> data;

  const CreateClientesEvent({required this.data});
  @override
  List<Object> get props => [data];
}

class GetClienteEvent extends ClienteEvent {
  final int clienteId;

  const GetClienteEvent({required this.clienteId});

  @override
  List<Object> get props => [clienteId];
}
