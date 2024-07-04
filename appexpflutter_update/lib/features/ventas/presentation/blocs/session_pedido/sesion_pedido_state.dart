part of 'sesion_pedido_bloc.dart';

sealed class SesionPedidoState extends Equatable {
  const SesionPedidoState();

  @override
  List<Object> get props => [];
}

final class PedidoInitial extends SesionPedidoState {}

final class PedidoLoading extends SesionPedidoState {}

final class PedidoLoaded extends SesionPedidoState {
  final PedidoEntity pedido;

  const PedidoLoaded({required this.pedido});

  @override
  List<Object> get props => [pedido];
}

final class PedidoDetalleLoaded extends SesionPedidoState {
  final PedidoEntity pedido;
  final String message;

  const PedidoDetalleLoaded({required this.message, required this.pedido});

  @override
  List<Object> get props => [message];
}

final class PedidoError extends SesionPedidoState {
  final String message;

  const PedidoError({required this.message});

  @override
  List<Object> get props => [message];
}
