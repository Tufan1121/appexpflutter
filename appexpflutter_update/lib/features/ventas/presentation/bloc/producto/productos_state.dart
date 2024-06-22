part of 'productos_bloc.dart';

sealed class ProductosState extends Equatable {
  const ProductosState();

  @override
  List<Object> get props => [];
}

class ProductoInitial extends ProductosState {}

class IbodegaProductosInitial extends ProductosState {}

class ProductoLoading extends ProductosState {}
class IbodegaProductosLoading extends ProductosState {}

class ProductosLoaded extends ProductosState {
  final List<ProductoEntity> productos;
  const ProductosLoaded({required this.productos});

  @override
  List<Object> get props => [productos];
}

class IbodegaProductosLoaded extends ProductosState {
  final List<ProductoEntity> productos;
  final List<ProductoEntity> selectedProducts; // Añadir esta línea

  const IbodegaProductosLoaded(
      {required this.productos,
      this.selectedProducts = const []}); 

  @override
  List<Object> get props => [productos, selectedProducts];
}

class MultiSelectState extends ProductosState {
  final List<ProductoEntity> productos;
  final List<ProductoEntity> selectedProducts;

  const MultiSelectState(
      {required this.productos, this.selectedProducts = const []});

  @override
  List<Object> get props => [productos, selectedProducts];
}

class ProductoError extends ProductosState {
  final List<ProductoEntity> productos;
  final String message;

  const ProductoError({required this.message, required this.productos});

  @override
  List<Object> get props => [message, productos];
}
