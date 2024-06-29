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

class AddProductToScannedEvent extends ProductosEvent {
  final ProductoEntity producto;

  const AddProductToScannedEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class RemoveProductEvent extends ProductosEvent {
  final ProductoEntity producto;

  const RemoveProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class AddSelectedProductsToScannedEvent extends ProductosEvent {
  final List<ProductoEntity> productos;
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

class UpdateProductQuantityEvent extends ProductosEvent {
  final String productoClave;
  final int newQuantity;

  const UpdateProductQuantityEvent(this.productoClave, this.newQuantity);

  @override
  List<Object> get props => [productoClave, newQuantity];
}

class UpdateProductSelectedPriceEvent extends ProductosEvent {
  final String productoClave;
  final int selectedPrice;

  const UpdateProductSelectedPriceEvent(this.productoClave, this.selectedPrice);

  @override
  List<Object> get props => [productoClave, selectedPrice];
}
