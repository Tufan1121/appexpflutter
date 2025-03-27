import 'package:equatable/equatable.dart';

class SesionEntity extends Equatable {
  final int idSesion;
  final String pedidos;
  final int idExpo;

  const SesionEntity({
    required this.idSesion,
    required this.pedidos,
    required this.idExpo,
  });

  @override
  List<Object?> get props => [
        idSesion,
        pedidos,
        idExpo,
      ];
}
