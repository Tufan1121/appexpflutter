import 'package:equatable/equatable.dart';

class GaleriaEntity extends Equatable {
  final String descripcio;
  final String pathima1;
  final String pathima2;

  const GaleriaEntity({
    required this.descripcio,
    required this.pathima1,
    required this.pathima2,
  });

  @override
  List<Object?> get props => [descripcio, pathima1, pathima2];
}
