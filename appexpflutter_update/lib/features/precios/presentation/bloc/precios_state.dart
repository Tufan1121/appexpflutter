part of 'precios_bloc.dart';

sealed class PreciosState extends Equatable {
  const PreciosState();

  @override
  List<Object> get props => [];
}

class PreciosInitial extends PreciosState {}

class PreciosLoading extends PreciosState {}

class PreciosLoaded extends PreciosState {
  final ProductoEntity producto;

  const PreciosLoaded({required this.producto});

  @override
  List<Object> get props => [producto];
}

/// Ficha agrupada estilo búsqueda global: el producto escaneado + todas las
/// medidas del mismo diseño encontradas en gspock (existencia > 0).
class PreciosFichaLoaded extends PreciosState {
  final ProductoEntity producto;
  final List<ProductoExpoEntity> productos;

  const PreciosFichaLoaded({required this.producto, required this.productos});

  @override
  List<Object> get props => [producto, productos];
}

class PreciosRelativosLoaded extends PreciosState {
  final ProductoEntity producto;
  final List<ProductoEntity> productos;
  const PreciosRelativosLoaded(
      {required this.producto, required this.productos});

  @override
  List<Object> get props => [producto, productos];
}

class PreciosError extends PreciosState {
  final String message;

  const PreciosError({required this.message});

  @override
  List<Object> get props => [message];
}
