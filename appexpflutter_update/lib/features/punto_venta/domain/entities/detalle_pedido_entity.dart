import 'package:equatable/equatable.dart';

class DetallePedidoEntity extends Equatable {
  final int idPedido;
  final String clave;
  final String clave2;
  final int cantidad;
  final double precio;

  /// Observaciones opcionales de la partida (columna `observa` en backend).
  final String observa;

  const DetallePedidoEntity({
    required this.idPedido,
    required this.clave,
    required this.clave2,
    required this.cantidad,
    required this.precio,
    this.observa = '',
  });

  @override
  List<Object?> get props => [
        idPedido,
        clave,
        clave2,
        cantidad,
        precio,
        observa,
      ];
}
