part of 'historial_bloc.dart';

sealed class HistorialState extends Equatable {
  const HistorialState();
  @override
  List<Object> get props => [];
}

class HistorialInitial extends HistorialState {}

class HistorialLoading extends HistorialState {}

class HistorialLoaded extends HistorialState {
  final List<HistorialPedidoEntity> historial;
  final String search;
  const HistorialLoaded({required this.historial, required this.search});

  @override
  List<Object> get props => [historial];
}

class HistorialCotizaLoaded extends HistorialState {
  final List<HistorialCotizaEntity> historial;
  final String search;
  const HistorialCotizaLoaded({required this.historial, required this.search});

  @override
  List<Object> get props => [historial];
}

class HistorialSesionLoaded extends HistorialState {
  final List<HistorialSesionEntity> historial;
  final String search;
  const HistorialSesionLoaded({required this.historial, required this.search});

  @override
  List<Object> get props => [historial];
}

class HistorialError extends HistorialState {
  final String message;
  const HistorialError({required this.message});

  @override
  List<Object> get props => [message];
}
