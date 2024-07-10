part of 'sesion_bloc.dart';

sealed class SesionState extends Equatable {
  const SesionState();

  @override
  List<Object> get props => [];
}

class SesionInitial extends SesionState {}

class SesionLoading extends SesionState {}

class SesionLoaded extends SesionState {
  final List<DetalleSesionEntity> detalleSesion;
  const SesionLoaded({required this.detalleSesion});
  @override
  List<Object> get props => [detalleSesion];
}

class SesionError extends SesionState {
  final String message;
  const SesionError({required this.message});
  @override
  List<Object> get props => [message];
}
