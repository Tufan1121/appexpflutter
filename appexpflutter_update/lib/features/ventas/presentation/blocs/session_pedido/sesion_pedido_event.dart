part of 'sesion_pedido_bloc.dart';

sealed class SesionPedidoEvent extends Equatable {
  const SesionPedidoEvent();

  @override
  List<Object> get props => [];
}

class PedidoAddEvent extends SesionPedidoEvent {
  final Map<String, dynamic> data;
  final List<DetallePedidoEntity> products;

  const PedidoAddEvent({required this.data, required this.products});

  @override
  List<Object> get props => [data];
}

class PedidoAddDetalleEvent extends SesionPedidoEvent {
  final SesionEntity pedido;
  final List<DetallePedidoEntity> products;

  const PedidoAddDetalleEvent({required this.products, required this.pedido});

  @override
  List<Object> get props => [products];
}

class PedidoAddIdPedidoEvent extends SesionPedidoEvent {
  final PedidoEntity pedido;

  const PedidoAddIdPedidoEvent({required this.pedido});

  @override
  List<Object> get props => [pedido];
}

class ClearPedidoStateEvent extends SesionPedidoEvent {}
