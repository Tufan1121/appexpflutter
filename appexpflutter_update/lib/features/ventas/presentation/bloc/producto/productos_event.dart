part of 'productos_bloc.dart';

sealed class ProductosEvent extends Equatable {
  const ProductosEvent();

  @override
  List<Object> get props => [];
}

class GetQRProductEvent extends ProductosEvent {
  final String clave;

  const GetQRProductEvent({required this.clave});
  @override
  List<Object> get props => [clave];
}

class GetProductEvent extends ProductosEvent {
  final String clave;

  const GetProductEvent({required this.clave});
  @override
  List<Object> get props => [clave];
}

class GetRelativedProductsEvent extends ProductosEvent {
  final ProductoEntity producto;

  const GetRelativedProductsEvent({required this.producto});

  @override
  List<Object> get props => [producto];
}

class SelectRelatedProductEvent extends ProductosEvent {
  final ProductoEntity selectedProduct;

  const SelectRelatedProductEvent(this.selectedProduct);

  @override
  List<Object> get props => [selectedProduct];
}

class ClearProductoStateEvent extends ProductosEvent {
  @override
  List<Object> get props => [];
}

class RemoveProductEvent extends ProductosEvent {
  final ProductoEntity producto;

  const RemoveProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}
