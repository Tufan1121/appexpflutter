import 'package:equatable/equatable.dart';

class TablaPreciosEntity extends Equatable {
  final String medidas;
  final int precio1;
  final int precio2;
  final int precio3;
  final int precio4;
  final int precio5;
  final int precio6;
  final int precio7;
  final int precio8;
  final int? precio9;
  final int? precio10;

  const TablaPreciosEntity({
    required this.medidas,
    required this.precio1,
    required this.precio2,
    required this.precio3,
    required this.precio4,
    required this.precio5,
    required this.precio6,
    required this.precio7,
    required this.precio8,
    this.precio9,
    this.precio10,
  });

  @override
  List<Object?> get props => [
        medidas,
        precio1,
        precio2,
        precio3,
        precio4,
        precio5,
        precio6,
        precio7,
        precio8,
        precio9,
        precio10,
      ];
}
