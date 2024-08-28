import 'package:equatable/equatable.dart';

class ProductoInvEntity extends Equatable {
  final String medidas;
  final String desalmacen;
  final int hm;

  const ProductoInvEntity({
    required this.medidas,
    required this.desalmacen,
    required this.hm,
  });

  @override
  List<Object?> get props => [
        medidas,
        hm,
        desalmacen,
      ];
}
