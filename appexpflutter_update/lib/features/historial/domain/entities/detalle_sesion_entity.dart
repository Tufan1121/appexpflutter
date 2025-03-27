import 'package:equatable/equatable.dart';

class DetalleSesionEntity extends Equatable {
  final int idDetallesesion;
  final int idSesion;
  final String clave;
  final String clave2;
  final double cantidad;
  final double precio;
  final double importe;
  final int estatus;
  final dynamic cerrado;
  final String pedidos;

  // Producto
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

  const DetalleSesionEntity({
    required this.idDetallesesion,
    required this.idSesion,
    required this.clave,
    required this.clave2,
    required this.cantidad,
    required this.precio,
    required this.importe,
    required this.estatus,
    required this.cerrado,
    required this.pedidos,

    // Producto
    required this.producto,
    required this.producto1,
    required this.descripcio,
    required this.medidas,
    required this.largo,
    required this.ancho,
    required this.rojo,
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
    required this.color3,
    required this.diseno,
    required this.unidad,
    required this.compo1,
    required this.compo2,
    required this.lava1,
    required this.lava2,
    required this.coo,
    required this.origenn,
    required this.fecha,
    required this.video1,
    required this.cunidad,
    required this.ccodigosat,
    required this.precio4,
    required this.precio5,
    required this.precio6,
    required this.precio7,
    required this.precio8,
    required this.precio9,
    required this.precio10,
    required this.fulldescrip,
    required this.descrip,
    required this.skuph,
    required this.precioph,
    required this.muestra,
    required this.bodega1,
    required this.bodega2,
    required this.bodega3,
    required this.bodega4,
  });

  DetalleSesionEntity copyWith({
    int? idDetallesesion,
    int? idSesion,
    String? clave,
    String? clave2,
    double? cantidad,
    double? precio,
    double? importe,
    int? estatus,
    dynamic cerrado,
    String? pedidos,
    String? producto,
    String? producto1,
    String? descripcio,
    String? diseno,
    String? medidas,
    double? largo,
    double? ancho,
    int? precio1,
    int? precio2,
    int? precio3,
    String? pathima1,
    String? pathima2,
    String? pathima3,
    String? pathima4,
    String? pathima5,
    String? pathima6,
    int? desa,
    String? color1,
    String? color2,
    String? unidad,
    String? compo1,
    String? compo2,
    String? lava1,
    String? lava2,
    String? origenn,
    DateTime? fecha,
    String? cunidad,
    String? ccodigosat,
    int? precio4,
    int? precio5,
    int? precio6,
    int? precio7,
    int? precio8,
    String? descrip,
    double? bodega1,
    double? bodega2,
    double? bodega3,
    double? bodega4,
  }) =>
      DetalleSesionEntity(
        idDetallesesion: idDetallesesion ?? this.idDetallesesion,
        idSesion: idSesion ?? this.idSesion,
        clave: clave ?? this.clave,
        clave2: clave2 ?? this.clave2,
        cantidad: cantidad ?? this.cantidad,
        precio: precio ?? this.precio,
        importe: importe ?? this.importe,
        estatus: estatus ?? this.estatus,
        cerrado: cerrado ?? this.cerrado,
        pedidos: pedidos ?? this.pedidos,
        producto: producto ?? this.producto,
        producto1: producto1 ?? this.producto1,
        descripcio: descripcio ?? this.descripcio,
        diseno: diseno ?? this.diseno,
        medidas: medidas ?? this.medidas,
        largo: largo ?? this.largo,
        ancho: ancho ?? this.ancho,
        rojo: rojo ?? rojo,
        precio1: precio1 ?? this.precio1,
        precio2: precio2 ?? this.precio2,
        precio3: precio3 ?? this.precio3,
        pathima1: pathima1 ?? this.pathima1,
        pathima2: pathima2 ?? this.pathima2,
        pathima3: pathima3 ?? this.pathima3,
        pathima4: pathima4 ?? this.pathima4,
        pathima5: pathima5 ?? this.pathima5,
        pathima6: pathima6 ?? this.pathima6,
        desa: desa ?? this.desa,
        color1: color1 ?? this.color1,
        color2: color2 ?? this.color2,
        color3: color3 ?? color3,
        unidad: unidad ?? this.unidad,
        compo1: compo1 ?? this.compo1,
        compo2: compo2 ?? this.compo2,
        lava1: lava1 ?? this.lava1,
        lava2: lava2 ?? this.lava2,
        coo: coo ?? coo,
        origenn: origenn ?? this.origenn,
        fecha: fecha ?? this.fecha,
        video1: video1 ?? video1,
        cunidad: cunidad ?? this.cunidad,
        ccodigosat: ccodigosat ?? this.ccodigosat,
        precio4: precio4 ?? this.precio4,
        precio5: precio5 ?? this.precio5,
        precio6: precio6 ?? this.precio6,
        precio7: precio7 ?? this.precio7,
        precio8: precio8 ?? this.precio8,
        precio9: precio9 ?? precio9,
        precio10: precio10 ?? precio10,
        fulldescrip: fulldescrip ?? fulldescrip,
        skuph: skuph ?? skuph,
        precioph: precioph ?? precioph,
        muestra: muestra ?? muestra,
        descrip: descrip ?? this.descrip,
        bodega1: bodega1 ?? this.bodega1,
        bodega2: bodega2 ?? this.bodega2,
        bodega3: bodega3 ?? this.bodega3,
        bodega4: bodega4 ?? this.bodega4,
      );

  @override
  List<Object?> get props => [
        idDetallesesion,
        idSesion,
        clave,
        clave2,
        cantidad,
        precio,
        importe,
        estatus,
        cerrado,
        pedidos,

        // Producto
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
        muestra,
        bodega1,
        bodega2,
        bodega3,
        bodega4,
      ];
}
