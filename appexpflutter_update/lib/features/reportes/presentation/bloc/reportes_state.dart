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

class ReportesTicketsLoaded extends ReportesState {
  final List<SalesTicketsEntity> salesPedidos;

  const ReportesTicketsLoaded(
      {required this.salesPedidos});

  @override
  List<Object> get props => [salesPedidos];
}


class ReportesPedidosLoaded extends ReportesState {
  final List<SalesPedidosEntity> salesPedidos;    

  const ReportesPedidosLoaded(
      {required this.salesPedidos});    

  @override
  List<Object> get props => [salesPedidos];
}



class AuthMovil extends ReportesState {
  final bool isAuthMovil;
  const AuthMovil({required this.isAuthMovil});

  @override
  List<Object> get props => [isAuthMovil];
}

class ReportesError extends ReportesState {
  final String message;
  const ReportesError({required this.message});

  @override
  List<Object> get props => [message];
}
