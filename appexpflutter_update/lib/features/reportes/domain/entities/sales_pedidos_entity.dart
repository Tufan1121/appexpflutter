import 'package:equatable/equatable.dart';

class SalesPedidosEntity extends Equatable {
  final double gtotal;
  final String fecham;

  const SalesPedidosEntity({
    required this.gtotal,
    required this.fecham,
  });

  @override
  List<Object?> get props => [gtotal, fecham];
}
