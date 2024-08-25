part of 'galeria_bloc.dart';

sealed class GaleriaState extends Equatable {
  const GaleriaState();

  @override
  List<Object> get props => [];
}

class GaleriaInitial extends GaleriaState {}

class GaleriaLoading extends GaleriaState {}

class GaleriaLoaded extends GaleriaState {
  final List<GaleriaEntity> galeria;
  

  const GaleriaLoaded({required this.galeria});

  @override
  List<Object> get props => [galeria];
}

class GaleriaError extends GaleriaState {
  final String message;

  const GaleriaError({required this.message});

  @override
  List<Object> get props => [message];
}


