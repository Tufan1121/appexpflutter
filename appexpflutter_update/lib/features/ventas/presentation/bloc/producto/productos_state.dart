part of 'productos_bloc.dart';

sealed class ProductosState extends Equatable {
  const ProductosState();

  @override
  List<Object> get props => [];
}

class ProductoInitial extends ProductosState {}

class ProductoLoading extends ProductosState {}

class ProductosLoaded extends ProductosState {
  final List<ProductoEntity> productos;
  const ProductosLoaded({required this.productos});

  @override
  List<Object> get props => [productos];
}

class ProductoError extends ProductosState {
  final List<ProductoEntity> productos;
  final String message;

  const ProductoError({required this.message, required this.productos});

  @override
  List<Object> get props => [message, productos];
}
