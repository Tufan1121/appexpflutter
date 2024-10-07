import 'package:equatable/equatable.dart';

class CotizaEntity extends Equatable {
  final int idCotiza;
  final String pedidos;
  final int idExpo;

  const CotizaEntity({
    required this.idCotiza,
    required this.pedidos,
    required this.idExpo,
  });

  @override
  List<Object?> get props => [
        idCotiza,
        pedidos,
        idExpo,
      ];
}
