part of 'precios_bloc.dart';

sealed class PreciosEvent extends Equatable {
  const PreciosEvent();

  @override
  List<Object> get props => [];
}

class GetQRProductEvent extends PreciosEvent {
  final String clave;

  const GetQRProductEvent({required this.clave});
  @override
  List<Object> get props => [clave];
}

class GetProductEvent extends PreciosEvent {
  final String clave;

  const GetProductEvent({required this.clave});
  @override
  List<Object> get props => [clave];
}

class GetRelativedProductsEvent extends PreciosEvent {
  final ProductoEntity producto;

  const GetRelativedProductsEvent({required this.producto});

  @override
  List<Object> get props => [producto];
}

class SelectRelatedProductEvent extends PreciosEvent {
  final ProductoEntity selectedProduct;

  const SelectRelatedProductEvent(this.selectedProduct);

  @override
  List<Object> get props => [selectedProduct];
}

class ClearPreciosStateEvent extends PreciosEvent {
  @override
  List<Object> get props => [];
}
