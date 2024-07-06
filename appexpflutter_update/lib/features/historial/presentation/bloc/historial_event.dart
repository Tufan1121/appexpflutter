part of 'historial_bloc.dart';

sealed class HistorialEvent extends Equatable {
  const HistorialEvent();
  @override
  List<Object> get props => [];
}

class GetHistorial extends HistorialEvent {
  final String parameter;
  final String endpoint;
  final String search;
  const GetHistorial({
    required this.parameter,
    required this.endpoint,
    required this.search,
  });

  @override
  List<Object> get props => [parameter, endpoint];
}


class ClearHistorialEvent extends HistorialEvent {}