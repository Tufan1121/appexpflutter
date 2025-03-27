part of 'medidas_cubit.dart';

sealed class MedidasState extends Equatable {
  const MedidasState();

  @override
  List<Object?> get props => [];
}

class MedidasInitial extends MedidasState {}

class MedidasLoading extends MedidasState {}

class MedidasLoaded extends MedidasState {
  final List<MedidasEntityInv> medidas;
  const MedidasLoaded({required this.medidas});

  @override
  List<Object?> get props => [medidas];
}

class MedidasError extends MedidasState {
  final String message;
  const MedidasError({required this.message});

  @override
  List<Object?> get props => [message];
}
