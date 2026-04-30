import 'package:equatable/equatable.dart';

class PermisosEntity extends Equatable {
  final bool inventarios;
  final bool precios;
  final bool cotizaciones;
  final bool historial;
  final bool galeria;

  const PermisosEntity({
    required this.inventarios,
    required this.precios,
    required this.cotizaciones,
    required this.historial,
    required this.galeria,
  });

  /// Default cuando el backend no devuelve el bloque `permisos`
  /// (por ejemplo, una version vieja del API). Coincide con el default
  /// "no encontrado" en mainPromos: solo inventarios habilitado.
  const PermisosEntity.restringido()
      : inventarios = true,
        precios = false,
        cotizaciones = false,
        historial = false,
        galeria = false;

  @override
  List<Object> get props =>
      [inventarios, precios, cotizaciones, historial, galeria];
}
