part of 'detalle_producto_bloc.dart';

sealed class DetalleProductoState extends Equatable {
  const DetalleProductoState();

  @override
  List<Object> get props => [];
}

class DetalleProductoInitial extends DetalleProductoState {}

class DetalleProductoLoading extends DetalleProductoState {}

class DetalleProductoLoaded extends DetalleProductoState {
  final ProductoConExistencias productosConExistencias;

  const DetalleProductoLoaded({required this.productosConExistencias});

  @override
  List<Object> get props => [productosConExistencias];
}

class DetalleProductoError extends DetalleProductoState {
  final String message;

  const DetalleProductoError({required this.message});

  @override
  List<Object> get props => [message];
}
