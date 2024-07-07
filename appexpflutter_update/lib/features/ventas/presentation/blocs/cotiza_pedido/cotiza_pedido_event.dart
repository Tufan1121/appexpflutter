part of 'cotiza_pedido_bloc.dart';

sealed class CotizaPedidoEvent extends Equatable {
  const CotizaPedidoEvent();

  @override
  List<Object> get props => [];
}

class PedidoAddEvent extends CotizaPedidoEvent {
  final Map<String, dynamic> data;
  final List<DetallePedido> products;

  const PedidoAddEvent({required this.data, required this.products});

  @override
  List<Object> get props => [data];
}

class PedidoAddDetalleEvent extends CotizaPedidoEvent {
  final CotizaEntity pedido;
  final List<DetallePedido> products;

  const PedidoAddDetalleEvent({required this.products, required this.pedido});

  @override
  List<Object> get props => [products];
}

class PedidoAddIdPedidoEvent extends CotizaPedidoEvent {
  final PedidoEntity pedido;

  const PedidoAddIdPedidoEvent({required this.pedido});

  @override
  List<Object> get props => [pedido];
}

class ClearPedidoStateEvent extends CotizaPedidoEvent {}
