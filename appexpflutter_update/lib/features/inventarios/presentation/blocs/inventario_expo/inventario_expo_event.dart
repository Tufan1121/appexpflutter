part of 'inventario_expo_bloc.dart';

sealed class InventarioExpoEvent extends Equatable {
  const InventarioExpoEvent();

  @override
  List<Object> get props => [];
}

class GetInventarioProductEvent extends InventarioExpoEvent {
  final Map<String, dynamic> data;

  const GetInventarioProductEvent({required this.data});

  @override
  List<Object> get props => [data];
}

class ClearInventarioProductoEvent extends InventarioExpoEvent {
  @override
  List<Object> get props => [];
}
