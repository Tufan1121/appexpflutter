part of 'busqueda_global_bloc.dart';

sealed class BusquedaGlobalState extends Equatable {
  const BusquedaGlobalState();
  
  @override
  List<Object> get props => [];
}

final class BusquedaGlobalInitial extends BusquedaGlobalState {}

class InventarioLoading extends BusquedaGlobalState {}

class InventarioProductosLoaded extends BusquedaGlobalState {
  final List<ProductoExpoEntity> productos; // Añadir esta línea

  const InventarioProductosLoaded({required this.productos});

  @override
  List<Object> get props => [productos];
}

class InventarioError extends BusquedaGlobalState {
  final String message;

  const InventarioError({required this.message});

  @override
  List<Object> get props => [message];
}
