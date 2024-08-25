part of 'galeria_bloc.dart';

sealed class GaleriaEvent extends Equatable {
  const GaleriaEvent();

  @override
  List<Object> get props => [];
}

class GetGaleriaEvent extends GaleriaEvent {
  final String? descripcion;
  final int? regg;

  const GetGaleriaEvent({this.descripcion, this.regg});

  @override
  List<Object> get props => [descripcion ?? '', regg ?? 0];
}

class ResetGaleriaEvent extends GaleriaEvent {}
