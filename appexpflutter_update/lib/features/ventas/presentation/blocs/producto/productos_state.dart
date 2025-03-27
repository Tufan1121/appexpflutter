part of 'productos_bloc.dart';

sealed class ProductosState extends Equatable {
  const ProductosState();

  @override
  List<Object> get props => [];
}

class ProductoInitial extends ProductosState {}

class ProductoLoading extends ProductosState {}

class ProductosLoaded extends ProductosState {
  final List<ProductoEntity> productos;
  const ProductosLoaded({required this.productos});

  @override
  List<Object> get props => [productos];
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
  final List<ProductoEntity> productos;
  final String message;

  const ProductoError({required this.message, required this.productos});

  @override
  List<Object> get props => [message, productos];
}
