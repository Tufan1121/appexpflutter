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

class ClearProductoIBodegaStateEvent extends ProductosEvent {}

class GetIbodegaProductEvent extends ProductosEvent {
  final Map<String, dynamic> data;

  const GetIbodegaProductEvent({required this.data});

  @override
  List<Object> get props => [data];
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

class StartMultiSelectEvent extends ProductosEvent {}

class ToggleProductSelectionEvent extends ProductosEvent {
  final ProductoEntity producto;

  const ToggleProductSelectionEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

class AddSelectedProductsToScannedEvent extends ProductosEvent {}

class UpdateProductEvent extends ProductosEvent {
  final ProductoEntity producto;

  const UpdateProductEvent(this.producto);

  @override
  List<Object> get props => [producto];
}

