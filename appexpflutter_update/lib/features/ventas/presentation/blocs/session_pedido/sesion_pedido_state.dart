part of 'sesion_pedido_bloc.dart';

sealed class SesionPedidoState extends Equatable {
  const SesionPedidoState();

  @override
  List<Object> get props => [];
}

class PedidoSesionInitial extends SesionPedidoState {}

class PedidoSesionLoading extends SesionPedidoState {}

final class PedidoLoaded extends SesionPedidoState {
  final SesionEntity pedido;

  const PedidoLoaded({required this.pedido});

  @override
  List<Object> get props => [pedido];
}

class PedidoDetalleSesionLoaded extends SesionPedidoState {
  final SesionEntity pedido;
  final String message;

  const PedidoDetalleSesionLoaded(
      {required this.message, required this.pedido});

  @override
  List<Object> get props => [message];
}

class PedidoFinalSesionLoaded extends SesionPedidoState {
  final String message;

  const PedidoFinalSesionLoaded({required this.message});

  @override
  List<Object> get props => [message];
}

class PedidoSesionError extends SesionPedidoState {
  final String message;

  const PedidoSesionError({required this.message});

  @override
  List<Object> get props => [message];
}
