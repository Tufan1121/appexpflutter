import 'package:equatable/equatable.dart';

class PedidoEntity extends Equatable {
  final int idPedido;
  final String pedidos;
  final int idExpo;

  const PedidoEntity({
    required this.idPedido,
    required this.pedidos,
    required this.idExpo,
  });

  @override
  List<Object?> get props => [
        idPedido,
        pedidos,
        idExpo,
      ];
}
