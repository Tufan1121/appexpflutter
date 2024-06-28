part of 'inventario_bodega_bloc.dart';

sealed class InventarioBodegaState extends Equatable {
  const InventarioBodegaState();

  @override
  List<Object> get props => [];
}

final class InventarioInitial extends InventarioBodegaState {}

class InventarioLoading extends InventarioBodegaState {}

class InventarioProductosLoaded extends InventarioBodegaState {
  final List<ProductoEntity> productos;
  final List<ProductoEntity> selectedProducts; // Añadir esta línea

  const InventarioProductosLoaded(
      {required this.productos, this.selectedProducts = const []});

  @override
  List<Object> get props => [productos, selectedProducts];
}

class InventarioError extends InventarioBodegaState {
  final String message;

  const InventarioError({required this.message});

  @override
  List<Object> get props => [message];
}
