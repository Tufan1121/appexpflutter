part of 'sesion_bloc.dart';

sealed class SesionEvent extends Equatable {
  const SesionEvent();

  @override
  List<Object> get props => [];
}

class GetDetalleSesionEvent extends SesionEvent {
  final String idSesion;
  const GetDetalleSesionEvent({required this.idSesion});

  @override
  List<Object> get props => [idSesion];
}

class AddSelectedProductsEvent extends SesionEvent {
  final List<DetalleSesionEntity> productos;
  const AddSelectedProductsEvent(this.productos);

  @override
  List<Object> get props => [productos];
}

class AddProductEvent extends SesionEvent {
  final DetalleSesionEntity producto;

  const AddProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class GetQRProductsEvent extends SesionEvent {
  final String clave;

  const GetQRProductsEvent({required this.clave});
  @override
  List<Object> get props => [clave];
}

class UpdateProductEvent extends SesionEvent {
  final DetalleSesionEntity producto;

  const UpdateProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class RemoveProductEvent extends SesionEvent {
  final DetalleSesionEntity producto;

  const RemoveProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class ClearSesionEvent extends SesionEvent {}
