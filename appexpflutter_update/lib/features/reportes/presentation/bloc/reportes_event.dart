part of 'reportes_bloc.dart';

sealed class ReportesEvent extends Equatable {
  const ReportesEvent();

  @override
  List<Object> get props => [];
}

class GetReportesPedidosEvent extends ReportesEvent {
  final String? fechaini;
  final String? fechafin;

  const GetReportesPedidosEvent({this.fechaini, this.fechafin});

  @override
  List<Object> get props => [fechaini ?? '', fechafin ?? ''];
}

class GetReportesTicketsEvent extends ReportesEvent {
  final String? fechaini;
  final String? fechafin;

  const GetReportesTicketsEvent({this.fechaini, this.fechafin});

  @override
  List<Object> get props => [fechaini ?? '', fechafin ?? ''];
}

class GetReportesVendedorEvent extends ReportesEvent {
  final String? fechaini;
  final String? fechafin;

  const GetReportesVendedorEvent({this.fechaini, this.fechafin});

  @override
  List<Object> get props => [fechaini ?? '', fechafin ?? ''];
}

class GetReportesMetaEvent extends ReportesEvent {}



class AuthMovilEvent extends ReportesEvent {
  final String movil;

  const AuthMovilEvent({required this.movil});

  @override
  List<Object> get props => [movil];
}
