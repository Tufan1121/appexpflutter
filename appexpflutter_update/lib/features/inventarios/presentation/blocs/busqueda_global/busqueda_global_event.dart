part of 'busqueda_global_bloc.dart';

sealed class BusquedaGlobalEvent extends Equatable {
  const BusquedaGlobalEvent();

  @override
  List<Object> get props => [];
}

class GetInventarioProductEvent extends BusquedaGlobalEvent {
  final Map<String, dynamic> data;

  const GetInventarioProductEvent({required this.data});

  @override
  List<Object> get props => [data];
}

class ClearInventarioProductoEvent extends BusquedaGlobalEvent {
  @override
  List<Object> get props => [];
}
