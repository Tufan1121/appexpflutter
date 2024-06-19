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
