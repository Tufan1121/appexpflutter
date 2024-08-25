import 'package:equatable/equatable.dart';

class MedidasEntity extends Equatable {
  final String medidas;

  const MedidasEntity({required this.medidas});

  @override
  List<Object?> get props => [medidas];
}
