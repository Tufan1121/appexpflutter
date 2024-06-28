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
  final int precio;
  final String fulldescrip;
  final String almacen;
  final String compos;
  final String origen;
  final String rojo;
  final String observac;
  final DateTime hobserva;
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
    required this.precio,
    required this.fulldescrip,
    required this.almacen,
    required this.compos,
    required this.origen,
    required this.rojo,
    required this.observac,
    required this.hobserva,
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
