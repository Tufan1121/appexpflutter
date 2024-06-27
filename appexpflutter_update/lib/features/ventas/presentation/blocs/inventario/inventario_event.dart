part of 'inventario_bloc.dart';

sealed class InventarioEvent extends Equatable {
  const InventarioEvent();

  @override
  List<Object> get props => [];
}

class GetInventarioProductEvent extends InventarioEvent {
  final Map<String, dynamic> data;

  const GetInventarioProductEvent({required this.data});

  @override
  List<Object> get props => [data];
}

class StartMultiSelectEvent extends InventarioEvent {}

class ToggleProductSelectionEvent extends InventarioEvent {
  final ProductoEntity producto;

  const ToggleProductSelectionEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class ClearInventarioProductoEvent extends InventarioEvent {
  @override
  List<Object> get props => [];
}