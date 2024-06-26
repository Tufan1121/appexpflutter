part of 'pedido_bloc.dart';

sealed class PedidoEvent extends Equatable {
  const PedidoEvent();

  @override
  List<Object> get props => [];
}

class PedidoAddEvent extends PedidoEvent {
  final Map<String, dynamic> data;
  final List<DetallePedido> products;

  const PedidoAddEvent({required this.data, required this.products});

  @override
  List<Object> get props => [data];
}

class PedidoAddDetalleEvent extends PedidoEvent {
  final int idPedido;
  final List<DetallePedido> products;

  const PedidoAddDetalleEvent({required this.products, required this.idPedido});

  @override
  List<Object> get props => [products];
}

class ClearPedidoStateEvent extends PedidoEvent {}


