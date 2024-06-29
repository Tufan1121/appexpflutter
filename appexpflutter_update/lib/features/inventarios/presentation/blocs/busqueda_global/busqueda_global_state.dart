part of 'busqueda_global_bloc.dart';

sealed class BusquedaGlobalState extends Equatable {
  const BusquedaGlobalState();
  
  @override
  List<Object> get props => [];
}

final class BusquedaGlobalInitial extends BusquedaGlobalState {}
