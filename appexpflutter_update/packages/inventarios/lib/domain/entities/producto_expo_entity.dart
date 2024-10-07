import 'package:equatable/equatable.dart';

class ProductoExpoEntity extends Equatable {
  final String producto;
  final String producto1;
  final String descripcio;
  final String diseno;
  final String medidas;
  final int hm;
  final double largo;
  final double ancho;
  final double? precio;
  final String fulldescrip;
  final String almacen;
  final String? compos;
  final String? origen;
  final String? rojo;
  final String observac;
  final DateTime? hobserva;
  final String pathima1;
  final String pathima2;
  final String pathima3;
  final String pathima4;
  final String pathima5;
  final String pathima6;
  final String video1;
  final String color1;
  final String color2;
  final String color3;
  final String lava1;
  final String lava2;
  final int precio1;
  final int precio2;
  final int precio3;
  final String desalmacen;

  const ProductoExpoEntity({
    required this.producto,
    required this.producto1,
    required this.descripcio,
    required this.diseno,
    required this.medidas,
    required this.hm,
    required this.largo,
    required this.ancho,
    this.precio,
    required this.fulldescrip,
    required this.almacen,
    this.compos,
    this.origen,
    this.rojo,
    required this.observac,
    this.hobserva,
    required this.pathima1,
    required this.pathima2,
    required this.pathima3,
    required this.pathima4,
    required this.pathima5,
    required this.pathima6,
    required this.video1,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.lava1,
    required this.lava2,
    required this.precio1,
    required this.precio2,
    required this.precio3,
    required this.desalmacen,
  });

  ProductoExpoEntity copyWith({
    String? producto,
    String? producto1,
    String? descripcio,
    String? diseno,
    String? medidas,
    int? hm,
    double? largo,
    double? ancho,
    double? precio,
    String? fulldescrip,
    String? almacen,
    String? compos,
    String? origen,
    String? rojo,
    String? observac,
    DateTime? hobserva,
    String? pathima1,
    String? pathima2,
    String? pathima3,
    String? pathima4,
    String? pathima5,
    String? pathima6,
    String? video1,
    String? color1,
    String? color2,
    String? color3,
    String? lava1,
    String? lava2,
    int? precio1,
    int? precio2,
    int? precio3,
    String? desalmacen,
  }) =>
      ProductoExpoEntity(
        producto: producto ?? this.producto,
        producto1: producto1 ?? this.producto1,
        descripcio: descripcio ?? this.descripcio,
        diseno: diseno ?? this.diseno,
        medidas: medidas ?? this.medidas,
        hm: hm ?? this.hm,
        largo: largo ?? this.largo,
        ancho: ancho ?? this.ancho,
        precio: precio ?? this.precio,
        fulldescrip: fulldescrip ?? this.fulldescrip,
        almacen: almacen ?? this.almacen,
        compos: compos ?? this.compos,
        origen: origen ?? this.origen,
        rojo: rojo ?? this.rojo,
        observac: observac ?? this.observac,
        hobserva: hobserva ?? this.hobserva,
        pathima1: pathima1 ?? this.pathima1,
        pathima2: pathima2 ?? this.pathima2,
        pathima3: pathima3 ?? this.pathima3,
        pathima4: pathima4 ?? this.pathima4,
        pathima5: pathima5 ?? this.pathima5,
        pathima6: pathima6 ?? this.pathima6,
        video1: video1 ?? this.video1,
        color1: color1 ?? this.color1,
        color2: color2 ?? this.color2,
        color3: color3 ?? this.color3,
        lava1: lava1 ?? this.lava1,
        lava2: lava2 ?? this.lava2,
        precio1: precio1 ?? this.precio1,
        precio2: precio2 ?? this.precio2,
        precio3: precio3 ?? this.precio3,
        desalmacen: desalmacen ?? this.desalmacen,
      );

  @override
  List<Object?> get props => [
        producto,
        producto1,
        descripcio,
        diseno,
        medidas,
        hm,
        largo,
        ancho,
        precio,
        fulldescrip,
        almacen,
        compos,
        origen,
        rojo,
        observac,
        hobserva,
        pathima1,
        pathima2,
        pathima3,
        pathima4,
        pathima5,
        pathima6,
        video1,
        color1,
        color2,
        color3,
        lava1,
        lava2,
        precio1,
        precio2,
        precio3,
        desalmacen,
      ];
}
