part of 'cotiza_pedido_bloc.dart';

sealed class CotizaPedidoState extends Equatable {
  const CotizaPedidoState();

  @override
  List<Object> get props => [];
}

final class PedidoInitial extends CotizaPedidoState {}

final class PedidoCotizaLoading extends CotizaPedidoState {}

final class PedidoLoaded extends CotizaPedidoState {
  final PedidoEntity pedido;

  const PedidoLoaded({required this.pedido});

  @override
  List<Object> get props => [pedido];
}

final class PedidoDetalleCotizaLoaded extends CotizaPedidoState {
  final CotizaEntity pedido;
  final String message;
  final String username;

  const PedidoDetalleCotizaLoaded(
      {required this.message, required this.pedido, required this.username});

  @override
  List<Object> get props => [message];
}

final class PedidoCotizaError extends CotizaPedidoState {
  final String message;

  const PedidoCotizaError({required this.message});

  @override
  List<Object> get props => [message];
}

final class ClearCotizaStateEvent extends CotizaPedidoState {}
