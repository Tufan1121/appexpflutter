part of 'precios_bloc.dart';

sealed class PreciosEvent extends Equatable {
  const PreciosEvent();

  @override
  List<Object> get props => [];
}

class GetQRPreciosEvent extends PreciosEvent {
  final String clave;

  const GetQRPreciosEvent({required this.clave});
  @override
  List<Object> get props => [clave];
}

class GetPreciosEvent extends PreciosEvent {
  final String clave;

  const GetPreciosEvent({required this.clave});
  @override
  List<Object> get props => [clave];
}
