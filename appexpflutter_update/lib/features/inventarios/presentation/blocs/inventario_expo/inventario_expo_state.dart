part of 'inventario_expo_bloc.dart';

sealed class InventarioExpoState extends Equatable {
  const InventarioExpoState();

  @override
  List<Object> get props => [];
}

final class InventarioExpoInitial extends InventarioExpoState {}

class InventarioLoading extends InventarioExpoState {}

class InventarioProductosLoaded extends InventarioExpoState {
  final List<ProductoExpoEntity> productos; // Añadir esta línea

  const InventarioProductosLoaded({required this.productos});

  @override
  List<Object> get props => [productos];
}

class InventarioError extends InventarioExpoState {
  final String message;

  const InventarioError({required this.message});

  @override
  List<Object> get props => [message];
}
