part of 'inventario_tienda_bloc.dart';

sealed class InventarioTiendaState extends Equatable {
  const InventarioTiendaState();

  @override
  List<Object> get props => [];
}

final class InventarioTiendaInitial extends InventarioTiendaState {}

class InventarioLoading extends InventarioTiendaState {}

class InventarioProductosLoaded extends InventarioTiendaState {
  final List<ProductoExpoEntity> productos; // Añadir esta línea
  final List<ProductoExpoEntity> selectedProducts;
  const InventarioProductosLoaded(
      {required this.productos, this.selectedProducts = const []});

  @override
  List<Object> get props => [productos];
}

class InventarioError extends InventarioTiendaState {
  final String message;

  const InventarioError({required this.message});

  @override
  List<Object> get props => [message];
}
