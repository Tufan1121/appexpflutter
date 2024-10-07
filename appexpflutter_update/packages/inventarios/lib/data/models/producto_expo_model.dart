
import 'package:inventarios/domain/entities/producto_expo_entity.dart';

class ProductoExpoModel extends ProductoExpoEntity{
  const ProductoExpoModel(
      {required super.producto,
      required super.producto1,
      required super.descripcio,
      required super.diseno,
      required super.medidas,
      required super.hm,
      required super.largo,
      required super.ancho,
      super.precio,
      required super.fulldescrip,
      required super.almacen,
      super.compos,
      super.origen,
      super.rojo,
      required super.observac,
      required super.hobserva,
      required super.pathima1,
      required super.pathima2,
      required super.pathima3,
      required super.pathima4,
      required super.pathima5,
      required super.pathima6,
      required super.video1,
      required super.color1,
      required super.color2,
      required super.color3,
      required super.lava1,
      required super.lava2,
      required super.precio1,
      required super.precio2,
      required super.precio3,
      required super.desalmacen});

  factory ProductoExpoModel.fromJson(Map<String, dynamic> json) =>
      ProductoExpoModel(
        producto: json["producto"],
        producto1: json["producto1"],
        descripcio: json["descripcio"],
        diseno: json["diseno"],
        medidas: json["medidas"],
        hm: json["hm"],
        largo: json["largo"]?.toDouble(),
        ancho: json["ancho"]?.toDouble(),
        precio: json["precio"],
        fulldescrip: json["fulldescrip"],
        almacen: json["almacen"],
        compos: json["compos"],
        origen: json["origen"],
        rojo: json["rojo"],
        observac: json["observac"],
        hobserva: json["hobserva"] == null ? null : DateTime.parse(json["hobserva"]),
        pathima1: json["pathima1"],
        pathima2: json["pathima2"],
        pathima3: json["pathima3"],
        pathima4: json["pathima4"],
        pathima5: json["pathima5"],
        pathima6: json["pathima6"],
        video1: json["video1"],
        color1: json["color1"],
        color2: json["color2"],
        color3: json["color3"],
        lava1: json["lava1"],
        lava2: json["lava2"],
        precio1: json["precio1"],
        precio2: json["precio2"],
        precio3: json["precio3"],
        desalmacen: json["desalmacen"],
      );

  Map<String, dynamic> toJson() => {
        "producto": producto,
        "producto1": producto1,
        "descripcio": descripcio,
        "diseno": diseno,
        "medidas": medidas,
        "hm": hm,
        "largo": largo,
        "ancho": ancho,
        "precio": precio,
        "fulldescrip": fulldescrip,
        "almacen": almacen,
        "compos": compos,
        "origen": origen,
        "rojo": rojo,
        "observac": observac,
        "hobserva": hobserva!.toIso8601String(),
        "pathima1": pathima1,
        "pathima2": pathima2,
        "pathima3": pathima3,
        "pathima4": pathima4,
        "pathima5": pathima5,
        "pathima6": pathima6,
        "video1": video1,
        "color1": color1,
        "color2": color2,
        "color3": color3,
        "lava1": lava1,
        "lava2": lava2,
        "precio1": precio1,
        "precio2": precio2,
        "precio3": precio3,
        "desalmacen": desalmacen,
      };

  ProductoExpoEntity toEntity() => ProductoExpoEntity(
      producto: producto,
      producto1: producto1,
      descripcio: descripcio,
      diseno: diseno,
      medidas: medidas,
      hm: hm,
      largo: largo,
      ancho: ancho,
      precio: precio,
      fulldescrip: fulldescrip,
      almacen: almacen,
      compos: compos,
      origen: origen,
      rojo: rojo,
      observac: observac,
      hobserva: hobserva,
      pathima1: pathima1,
      pathima2: pathima2,
      pathima3: pathima3,
      pathima4: pathima4,
      pathima5: pathima5,
      pathima6: pathima6,
      video1: video1,
      color1: color1,
      color2: color2,
      color3: color3,
      lava1: lava1,
      lava2: lava2,
      precio1: precio1,
      precio2: precio2,
      precio3: precio3,
      desalmacen: desalmacen);
}