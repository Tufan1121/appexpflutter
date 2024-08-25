part of 'detalle_galeria_bloc.dart';

sealed class DetalleGaleriaState extends Equatable {
  const DetalleGaleriaState();

  @override
  List<Object> get props => [];
}

class DetalleGaleriaInitial extends DetalleGaleriaState {}

class DetalleGaleriaLoading extends DetalleGaleriaState {}

class DetalleGaleriaLoaded extends DetalleGaleriaState {
  final List<ProductoConMedidas> productosConMedidas;

  const DetalleGaleriaLoaded({required this.productosConMedidas});

  @override
  List<Object> get props => [productosConMedidas];
}

class DetalleGaleriaError extends DetalleGaleriaState {
  final String message;

  const DetalleGaleriaError({required this.message});

  @override
  List<Object> get props => [message];
}
