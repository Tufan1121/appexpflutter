part of 'historial_bloc.dart';

sealed class HistorialEvent extends Equatable {
  const HistorialEvent();
  @override
  List<Object> get props => [];
}

class GetHistorialPedido extends HistorialEvent {
  final String parameter;
  final String search;
  const GetHistorialPedido({
    required this.parameter,
    required this.search,
  });

  @override
  List<Object> get props => [parameter, search];
}

class GetHistorialSesion extends HistorialEvent {
  final String parameter;
  final String search;
  const GetHistorialSesion({
    required this.parameter,
    required this.search,
  });

  @override
  List<Object> get props => [parameter, search];
}

class GetHistorialCotiza extends HistorialEvent {
  final String parameter;
  final String search;
  const GetHistorialCotiza({
    required this.parameter,
    required this.search,
  });

  @override
  List<Object> get props => [parameter, search];
}

class ClearHistorialEvent extends HistorialEvent {}
