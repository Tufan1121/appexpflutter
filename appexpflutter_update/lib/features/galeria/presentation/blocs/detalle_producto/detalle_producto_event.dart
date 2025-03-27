part of 'detalle_producto_bloc.dart';

sealed class DetalleProductoEvent extends Equatable {
  const DetalleProductoEvent();

  @override
  List<Object> get props => [];
}

class GetProductsEvent extends DetalleProductoEvent {
  final ProductoGalEntity producto;

  const GetProductsEvent({required this.producto});

  @override
  List<Object> get props => [producto];
}

class ResetDetalleProductoEvent extends DetalleProductoEvent {}
