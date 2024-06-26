part of 'pedido_bloc.dart';

sealed class PedidoState extends Equatable {
  const PedidoState();

  @override
  List<Object> get props => [];
}

final class PedidoInitial extends PedidoState {}

final class PedidoLoading extends PedidoState {}

final class PedidoLoaded extends PedidoState {
  final int idPedido;

  const PedidoLoaded({required this.idPedido});

  @override
  List<Object> get props => [idPedido];
}

final class PedidoDetalleLoaded extends PedidoState {
  final String message;

  const PedidoDetalleLoaded({required this.message});

  @override
  List<Object> get props => [message];
}

final class PedidoError extends PedidoState {
  final String message;

  const PedidoError({required this.message});

  @override
  List<Object> get props => [message];
}
