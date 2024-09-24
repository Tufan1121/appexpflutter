part of 'productos_tienda_bloc.dart';

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
  final ProductoExpoEntity producto;

  const GetRelativedProductsEvent({required this.producto});

  @override
  List<Object> get props => [producto];
}

class SelectRelatedProductEvent extends ProductosEvent {
  final ProductoExpoEntity selectedProduct;

  const SelectRelatedProductEvent(this.selectedProduct);

  @override
  List<Object> get props => [selectedProduct];
}

class ClearProductoStateEvent extends ProductosEvent {
  @override
  List<Object> get props => [];
}

class AddProductToScannedEvent extends ProductosEvent {
  final ProductoExpoEntity producto;

  const AddProductToScannedEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class RemoveProductEvent extends ProductosEvent {
  final ProductoExpoEntity producto;

  const RemoveProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class AddSelectedProductsToScannedEvent extends ProductosEvent {
  final List<ProductoExpoEntity> productos;
  const AddSelectedProductsToScannedEvent(this.productos);

  @override
  List<Object> get props => [productos];
}

class UpdateProductEvent extends ProductosEvent {
  final ProductoEntity producto;

  const UpdateProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

