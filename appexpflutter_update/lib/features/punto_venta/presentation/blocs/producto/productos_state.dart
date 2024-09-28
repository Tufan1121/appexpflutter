part of 'productos_tienda_bloc.dart';

sealed class ProductosState extends Equatable {
  const ProductosState();

  @override
  List<Object> get props => [];
}

class ProductoInitial extends ProductosState {}

class ProductoLoading extends ProductosState {}

class ProductosLoaded extends ProductosState {
  final List<ProductoExpoEntity> productos;
  final bool? existencia;
  const ProductosLoaded({required this.productos, this.existencia});

  @override
  List<Object> get props => [productos, existencia ?? 0.0];
}

class ProductosCountUpdated extends ProductosState {
  final List<int> countList;

  const ProductosCountUpdated({required this.countList});

  @override
  List<Object> get props => [countList];
}

class ProductosPriceUpdated extends ProductosState {
  final List<int?> selectedPriceList;

  const ProductosPriceUpdated({required this.selectedPriceList});

  @override
  List<Object> get props => [selectedPriceList];
}

class ProductoError extends ProductosState {
  final List<ProductoExpoEntity> productos;
  final String message;
  final bool? existencia;

  const ProductoError(
      {required this.message, required this.productos, this.existencia});

  @override
  List<Object> get props => [message, productos, existencia ?? false];
}
