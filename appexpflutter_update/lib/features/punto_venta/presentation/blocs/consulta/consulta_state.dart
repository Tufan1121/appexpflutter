part of 'consulta_bloc.dart';

sealed class ConsultaState extends Equatable {
  @override
  List<Object> get props => [];
}

class ConsultaInitial extends ConsultaState {}

class ConsultaLoading extends ConsultaState {}

class ConsultaLoaded extends ConsultaState {
  final List<TicketsEntity> tickets;
  ConsultaLoaded({required this.tickets});

  @override
  List<Object> get props => [tickets];
}

class ConsultaError extends ConsultaState {
  final String message;
  ConsultaError({required this.message});

  @override
  List<Object> get props => [message];
}
