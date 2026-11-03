import 'package:equatable/equatable.dart';

class GaleriaEntity extends Equatable {
  final String descripcio;
  final String pathima1;
  final String pathima2;
  // Composición (compo1 + compo2) y país de origen de gproducto; vacíos si
  // el backend no los manda.
  final String composicion;
  final String origen;

  const GaleriaEntity({
    required this.descripcio,
    required this.pathima1,
    required this.pathima2,
    this.composicion = '',
    this.origen = '',
  });

  @override
  List<Object?> get props =>
      [descripcio, pathima1, pathima2, composicion, origen];
}
