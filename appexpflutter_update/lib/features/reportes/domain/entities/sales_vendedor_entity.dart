import 'package:equatable/equatable.dart';

class SalesVendedorEntity extends Equatable {
  final String vendedor;
  final double pedidos;
  final double puntoventa;
  final double gtotal;

  const SalesVendedorEntity({
    required this.vendedor,
    required this.pedidos,
    required this.puntoventa,
    required this.gtotal,
  });

  @override
  List<Object?> get props => [vendedor, pedidos, puntoventa, gtotal];
}
