part of 'inventario_tienda_bloc.dart';

sealed class InventarioTiendaEvent extends Equatable {
  const InventarioTiendaEvent();

  @override
  List<Object> get props => [];
}

class GetInventarioProductEvent extends InventarioTiendaEvent {
  final Map<String, dynamic> data;

  const GetInventarioProductEvent({required this.data});

  @override
  List<Object> get props => [data];
}
class StartMultiSelectEvent extends InventarioTiendaEvent {}

class ToggleProductSelectionEvent extends InventarioTiendaEvent {
  final ProductoExpoEntity producto;

  const ToggleProductSelectionEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class ClearInventarioProductoEvent extends InventarioTiendaEvent {
  @override
  List<Object> get props => [];
}
