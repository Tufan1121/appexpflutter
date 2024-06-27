part of 'inventario_bloc.dart';

sealed class InventarioState extends Equatable {
  const InventarioState();
  
  @override
  List<Object> get props => [];
}

final class InventarioInitial extends InventarioState {}

class InventarioLoading extends InventarioState {}

class InventarioProductosLoaded extends InventarioState {
  final List<ProductoEntity> productos;
  final List<ProductoEntity> selectedProducts; // Añadir esta línea

  const InventarioProductosLoaded(
      {required this.productos, this.selectedProducts = const []});

  @override
  List<Object> get props => [productos, selectedProducts];
}

class MultiSelectState extends InventarioState {
  final List<ProductoEntity> productos;
  final List<ProductoEntity> selectedProducts;

  const MultiSelectState(
      {required this.productos, this.selectedProducts = const []});

  @override
  List<Object> get props => [productos, selectedProducts];
}

class InventarioError extends InventarioState {
  final String message;

  const InventarioError({required this.message });

  @override
  List<Object> get props => [message];
}
