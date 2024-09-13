import 'package:equatable/equatable.dart';

class MedidasEntityInv extends Equatable {
  final String medida;
  final double largo;
  final double ancho;
  final double cm;

  const MedidasEntityInv({
    required this.medida,
    required this.largo,
    required this.ancho,
    required this.cm,
  });

  @override
  List<Object?> get props => [medida, largo, ancho, cm];
}
