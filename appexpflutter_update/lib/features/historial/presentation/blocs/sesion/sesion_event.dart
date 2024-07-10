part of 'sesion_bloc.dart';

sealed class SesionEvent extends Equatable {
  const SesionEvent();

  @override
  List<Object> get props => [];
}

class GetDetalleSesionEvent extends SesionEvent {
  final String idSesion;
  const GetDetalleSesionEvent({required this.idSesion});

  @override
  List<Object> get props => [idSesion];
}

class ClearSesionEvent extends SesionEvent {}
