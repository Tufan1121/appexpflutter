part of 'reportes_bloc.dart';

sealed class ReportesState extends Equatable {
  const ReportesState();

  @override
  List<Object> get props => [];
}

class ReportesInitial extends ReportesState {}

class ReportesLoading extends ReportesState {}

class ReportesLoaded extends ReportesState {
  final List<SalesPedidosEntity> salesPedidos;
  final List<SalesTicketsEntity> salesTickets;

  const ReportesLoaded(
      {required this.salesPedidos, required this.salesTickets});

  @override
  List<Object> get props => [salesPedidos, salesTickets];
}

class ReportesError extends ReportesState {
  final String message;
  const ReportesError({required this.message});

  @override
  List<Object> get props => [message];
}
