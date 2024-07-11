part of 'sesion_pedido_bloc.dart';

sealed class SesionPedidoEvent extends Equatable {
  const SesionPedidoEvent();

  @override
  List<Object> get props => [];
}

class PedidoAddSesionEvent extends SesionPedidoEvent {
  final Map<String, dynamic> data;
  final List<DetallePedidoEntity> products;

  const PedidoAddSesionEvent({required this.data, required this.products});

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

class PedidoAddIdSesionEvent extends SesionPedidoEvent {
  final int idSesion;

  const PedidoAddIdSesionEvent({required this.idSesion});

  @override
  List<Object> get props => [idSesion];
}

class ClearPedidoSesionEvent extends SesionPedidoEvent {}
