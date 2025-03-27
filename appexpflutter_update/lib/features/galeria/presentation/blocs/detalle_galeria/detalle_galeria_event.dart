part of 'detalle_galeria_bloc.dart';

sealed class DetalleGaleriaEvent extends Equatable {
  const DetalleGaleriaEvent();

  @override
  List<Object> get props => [];
}

class GetProductEvent extends DetalleGaleriaEvent {
  final String descripcion;

  const GetProductEvent({required this.descripcion});

  @override
  List<Object> get props => [descripcion];
}

class GetMedidasEvent extends DetalleGaleriaEvent {
  final String descripcion;
  final String diseno;
  final List<ProductoGalEntity> productos;

  const GetMedidasEvent({
    required this.descripcion,
    required this.diseno,
    required this.productos,
  });

  @override
  List<Object> get props => [descripcion, diseno, productos];
}

class ResetDetalleGaleriaEvent extends DetalleGaleriaEvent {}
