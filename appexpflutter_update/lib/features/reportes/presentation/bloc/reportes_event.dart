part of 'reportes_bloc.dart';

sealed class ReportesEvent extends Equatable {
  const ReportesEvent();

  @override
  List<Object> get props => [];
}

class GetReportesPedidosEvent extends ReportesEvent {}

class GetReportesTicketsEvent extends ReportesEvent {}



class AuthMovilEvent extends ReportesEvent {
  final String movil;

  const AuthMovilEvent({required this.movil});

  @override
  List<Object> get props => [movil];
}
