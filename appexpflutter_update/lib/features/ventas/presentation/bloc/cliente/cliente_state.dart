part of 'cliente_bloc.dart';

sealed class ClienteState extends Equatable {
  const ClienteState();

  @override
  List<Object> get props => [];
}

class ClienteInitial extends ClienteState {}

class ClienteLoading extends ClienteState {}

class ClienteLoaded extends ClienteState {
  final List<ClienteEntity> clientes;
  final String? message; 

  const ClienteLoaded({required this.clientes, this.message});

  @override
  List<Object> get props => [clientes, message ?? ''];
}

class ClienteError extends ClienteState {
  final String message;

  const ClienteError({required this.message});

  @override
  List<Object> get props => [message];
}
