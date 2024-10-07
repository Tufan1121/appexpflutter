import 'package:equatable/equatable.dart';

class PedidoEntity extends Equatable {
  final int idPedido;
  final String pedidos;

  const PedidoEntity({
    required this.idPedido,
    required this.pedidos,
  });

  @override
  List<Object?> get props => [
        idPedido,
        pedidos,
      ];
}
