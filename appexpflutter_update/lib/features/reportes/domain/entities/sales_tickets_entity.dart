import 'package:equatable/equatable.dart';

class SalesTicketsEntity extends Equatable {
  final double gtotal;
  final String fecham;

  const SalesTicketsEntity({
    required this.gtotal,
    required this.fecham,
  });

  @override
  List<Object?> get props => [gtotal, fecham];
}
