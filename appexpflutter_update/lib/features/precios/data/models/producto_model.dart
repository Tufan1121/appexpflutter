import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';

class ProductoModel extends ProductoEntity
    with EntityConvertible<ProductoModel, ProductoEntity> {
  const ProductoModel({
    required super.producto,
    required super.producto1,
    required super.descripcio,
    required super.diseno,
    required super.medidas,
    required super.largo,
    required super.ancho,
    super.rojo,
    required super.precio1,
    required super.precio2,
    required super.precio3,
    required super.pathima1,
    required super.pathima2,
    required super.pathima3,
    required super.pathima4,
    required super.pathima5,
    required super.pathima6,
    required super.desa,
    required super.color1,
    required super.color2,
    super.color3,
    required super.unidad,
    required super.compo1,
    required super.compo2,
    required super.lava1,
    required super.lava2,
    super.coo,
    required super.origenn,
    required super.fecha,
    super.video1,
    required super.cunidad,
    required super.ccodigosat,
    required super.precio4,
    required super.precio5,
    required super.precio6,
    required super.precio7,
    required super.precio8,
    super.precio9,
    super.precio10,
    super.fulldescrip,
    required super.descrip,
    super.skuph,
    super.precioph,
    super.muestra,
    required super.bodega1,
    required super.bodega2,
    required super.bodega3,
    required super.bodega4,
  });
  factory ProductoModel.fromJson(Map<String, dynamic> json) {
   // la cadena de fecha en un objeto DateTime
    DateTime? parsedDate;
    if (json['fecha'] != null) {
      try {
        parsedDate = DateTime.parse(json['fecha']);
      } catch (e) {
        parsedDate = null; 
      }
    }

    return ProductoModel(
      producto: json['producto'],
      producto1: json['producto1'],
      descripcio: json['descripcio'],
      diseno: json['diseno'],
      medidas: json['medidas'],
      largo: (json['largo'] as num).toDouble(),
      ancho: (json['ancho'] as num).toDouble(),
      rojo: json['rojo'],
      precio1: json['precio1'],
      precio2: json['precio2'],
      precio3: json['precio3'],
      pathima1: json['pathima1'],
      pathima2: json['pathima2'],
      pathima3: json['pathima3'],
      pathima4: json['pathima4'],
      pathima5: json['pathima5'],
      pathima6: json['pathima6'],
      desa: json['desa'],
      color1: json['color1'],
      color2: json['color2'],
      color3: json['color3'],
      unidad: json['unidad'],
      compo1: json['compo1'],
      compo2: json['compo2'],
      lava1: json['lava1'],
      lava2: json['lava2'],
      coo: json['coo'],
      origenn: json['origenn'],
      fecha: parsedDate!, // Use the parsed DateTime object
      video1: json['video1'],
      cunidad: json['cunidad'],
      ccodigosat: json['ccodigosat'],
      precio4: json['precio4'],
      precio5: json['precio5'],
      precio6: json['precio6'],
      precio7: json['precio7'],
      precio8: json['precio8'],
      precio9: json['precio9'],
      precio10: json['precio10'],
      fulldescrip: json['fulldescrip'],
      descrip: json['descrip'],
      skuph: json['skuph'],
      precioph: json['precioph'],
      muestra: json['muestra'],
      bodega1: json['bodega1'],
      bodega2: json['bodega2'],
      bodega3: json['bodega3'],
      bodega4: json['bodega4'],
    );
  }

  @override
  ProductoEntity toEntity() => ProductoEntity(
        producto: producto,
        producto1: producto1,
        descripcio: descripcio,
        diseno: diseno,
        medidas: medidas,
        largo: largo,
        ancho: ancho,
        rojo: rojo,
        precio1: precio1,
        precio2: precio2,
        precio3: precio3,
        pathima1: pathima1,
        pathima2: pathima2,
        pathima3: pathima3,
        pathima4: pathima4,
        pathima5: pathima5,
        pathima6: pathima6,
        desa: desa,
        color1: color1,
        color2: color2,
        color3: color3,
        unidad: unidad,
        compo1: compo1,
        compo2: compo2,
        lava1: lava1,
        lava2: lava2,
        coo: coo,
        origenn: origenn,
        fecha: fecha,
        video1: video1,
        cunidad: cunidad,
        ccodigosat: ccodigosat,
        precio4: precio4,
        precio5: precio5,
        precio6: precio6,
        precio7: precio7,
        precio8: precio8,
        precio9: precio9,
        precio10: precio10,
        fulldescrip: fulldescrip,
        descrip: descrip,
        skuph: skuph,
        precioph: precioph,
        muestra: muestra,
        bodega1: bodega1,
        bodega2: bodega2,
        bodega3: bodega3,
        bodega4: bodega4,
      );
}
