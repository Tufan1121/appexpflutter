part of 'consulta_bloc.dart';

sealed class ConsultaEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetSalesTicketsEvent extends ConsultaEvent {
  final String fechaInicio;
  final String fechaFin;
  GetSalesTicketsEvent({required this.fechaInicio, required this.fechaFin});

  @override
  List<Object> get props => [fechaInicio, fechaFin];
}

class ClearTicketsEvent extends ConsultaEvent {}
