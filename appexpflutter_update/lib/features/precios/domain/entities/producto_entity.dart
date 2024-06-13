import 'package:equatable/equatable.dart';

class ProductoEntity extends Equatable {
  final String producto;
  final String producto1;
  final String descripcio;
  final String diseno;
  final String medidas;
  final double largo;
  final double ancho;
  final dynamic rojo;
  final int precio1;
  final int precio2;
  final int precio3;
  final String pathima1;
  final String pathima2;
  final String pathima3;
  final String pathima4;
  final String pathima5;
  final String pathima6;
  final int desa;
  final String color1;
  final String color2;
  final String? color3;
  final String unidad;
  final String compo1;
  final String compo2;
  final String lava1;
  final String lava2;
  final dynamic coo;
  final String origenn;
  final DateTime fecha;
  final String? video1;
  final String cunidad;
  final String ccodigosat;
  final int precio4;
  final int precio5;
  final int precio6;
  final int precio7;
  final int precio8;
  final int? precio9;
  final int? precio10;
  final String? fulldescrip;
  final String descrip;
  final dynamic skuph;
  final dynamic precioph;
  final dynamic muestra;
  final double bodega1;
  final double bodega2;
  final double bodega3;
  final double bodega4;

  const ProductoEntity({
    required this.producto,
    required this.producto1,
    required this.descripcio,
    required this.diseno,
    required this.medidas,
    required this.largo,
    required this.ancho,
    this.rojo,
    required this.precio1,
    required this.precio2,
    required this.precio3,
    required this.pathima1,
    required this.pathima2,
    required this.pathima3,
    required this.pathima4,
    required this.pathima5,
    required this.pathima6,
    required this.desa,
    required this.color1,
    required this.color2,
    this.color3,
    required this.unidad,
    required this.compo1,
    required this.compo2,
    required this.lava1,
    required this.lava2,
    this.coo,
    required this.origenn,
    required this.fecha,
    this.video1,
    required this.cunidad,
    required this.ccodigosat,
    required this.precio4,
    required this.precio5,
    required this.precio6,
    required this.precio7,
    required this.precio8,
    this.precio9,
    this.precio10,
    this.fulldescrip,
    required this.descrip,
    this.skuph,
    this.precioph,
    this.muestra,
    required this.bodega1,
    required this.bodega2,
    required this.bodega3,
    required this.bodega4,
  });

  @override
  List<Object?> get props => [
        producto,
        producto1,
        descripcio,
        diseno,
        medidas,
        largo,
        ancho,
        rojo,
        precio1,
        precio2,
        precio3,
        pathima1,
        pathima2,
        pathima3,
        pathima4,
        pathima5,
        pathima6,
        desa,
        color1,
        color2,
        color3,
        unidad,
        compo1,
        compo2,
        lava1,
        lava2,
        coo,
        origenn,
        fecha,
        video1,
        cunidad,
        ccodigosat,
        precio4,
        precio5,
        precio6,
        precio7,
        precio8,
        precio9,
        precio10,
        fulldescrip,
        descrip,
        skuph,
        precioph,
      ];
}
