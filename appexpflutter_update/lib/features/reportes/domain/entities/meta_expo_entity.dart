import 'package:equatable/equatable.dart';

class MetaExpoEntity extends Equatable {
  final double meta;
  final double alcanzado;
  final double pedidos;
  final double puntoventa;
  final double falta;
  final double porcentaje;

  const MetaExpoEntity({
    required this.meta,
    required this.alcanzado,
    required this.pedidos,
    required this.puntoventa,
    required this.falta,
    required this.porcentaje,
  });

  @override
  List<Object?> get props =>
      [meta, alcanzado, pedidos, puntoventa, falta, porcentaje];
}
