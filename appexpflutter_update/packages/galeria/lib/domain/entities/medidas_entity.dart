import 'package:equatable/equatable.dart';

class MedidasEntity extends Equatable {
  final String medidas;
  final int precio;

  const MedidasEntity({required this.medidas, required this.precio});

  @override
  List<Object?> get props => [medidas, precio];
}
