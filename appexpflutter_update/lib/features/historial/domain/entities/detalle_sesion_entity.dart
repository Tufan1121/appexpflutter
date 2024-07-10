import 'package:equatable/equatable.dart';

class DetalleSesionEntity extends Equatable {
  final int idDetallesesion;
  final int idSesion;
  final String clave;
  final String clave2;
  final double cantidad;
  final double precio;
  final double importe;
  final int estatus;
  final dynamic cerrado;
  final String pedidos;

  const DetalleSesionEntity({
    required this.idDetallesesion,
    required this.idSesion,
    required this.clave,
    required this.clave2,
    required this.cantidad,
    required this.precio,
    required this.importe,
    required this.estatus,
    required this.cerrado,
    required this.pedidos,
  });

  @override
  List<Object?> get props => [
        idDetallesesion,
        idSesion,
        clave,
        clave2,
        cantidad,
        precio,
        importe,
        estatus,
        cerrado,
        pedidos,
      ];
}
