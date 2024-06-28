part of 'inventario_bodega_bloc.dart';

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

class ClearInventarioProductoEvent extends InventarioEvent {
  @override
  List<Object> get props => [];
}