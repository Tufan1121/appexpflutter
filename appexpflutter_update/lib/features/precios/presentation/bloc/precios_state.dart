part of 'precios_bloc.dart';

sealed class PreciosState extends Equatable {
  const PreciosState();

  @override
  List<Object> get props => [];
}

final class PreciosInitial extends PreciosState {}

class PreciosLoading extends PreciosState {}

class PreciosLoaded extends PreciosState {
  final ProductoEntity producto;

  const PreciosLoaded({required this.producto});

  @override
  List<Object> get props => [producto];
}

class PreciosRelativosLoaded extends PreciosState {
  final ProductoEntity producto;
  final List<ProductoEntity> productos;
  const PreciosRelativosLoaded(
      {required this.producto, required this.productos});

  @override
  List<Object> get props => [producto, productos];
}

final class PreciosError extends PreciosState {
  final String message;

  const PreciosError({required this.message});

  @override
  List<Object> get props => [message];
}
