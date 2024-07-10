import 'package:equatable/equatable.dart';

class DetallePedidoEntity extends Equatable {
  final int idPedido;
  final String clave;
  final String clave2;
  final int cantidad;
  final double precio;

  const DetallePedidoEntity({
    required this.idPedido,
    required this.clave,
    required this.clave2,
    required this.cantidad,
    required this.precio,
  });

  @override
  List<Object?> get props => [
        idPedido,
        clave,
        clave2,
        cantidad,
        precio,
      ];
}
