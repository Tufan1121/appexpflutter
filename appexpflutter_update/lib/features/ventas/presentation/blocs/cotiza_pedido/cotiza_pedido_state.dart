part of 'cotiza_pedido_bloc.dart';

sealed class CotizaPedidoState extends Equatable {
  const CotizaPedidoState();

  @override
  List<Object> get props => [];
}

final class PedidoInitial extends CotizaPedidoState {}

final class PedidoLoading extends CotizaPedidoState {}

final class PedidoLoaded extends CotizaPedidoState {
  final PedidoEntity pedido;

  const PedidoLoaded({required this.pedido});

  @override
  List<Object> get props => [pedido];
}

final class PedidoDetalleLoaded extends CotizaPedidoState {
  final CotizaEntity pedido;
  final String message;

  const PedidoDetalleLoaded({required this.message, required this.pedido});

  @override
  List<Object> get props => [message];
}

final class PedidoError extends CotizaPedidoState {
  final String message;

  const PedidoError({required this.message});

  @override
  List<Object> get props => [message];
}
