part of 'cantidad_precio_cubit.dart';

sealed class CantidadPrecioState extends Equatable {
  const CantidadPrecioState();

  @override
  List<Object> get props => [];
}

final class CantidadPrecioInitial extends CantidadPrecioState {}

class CantidadState extends CantidadPrecioState {
  final int cantidad;
  final int selectedPrice;

  const CantidadState(this.cantidad, this.selectedPrice);

  @override
  List<Object> get props => [cantidad, selectedPrice];
}
