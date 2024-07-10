import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';

class DetalleSesionModel extends DetalleSesionEntity
    with EntityConvertible<DetalleSesionModel, DetalleSesionEntity> {
  const DetalleSesionModel({
    required super.idDetallesesion,
    required super.idSesion,
    required super.clave,
    required super.clave2,
    required super.cantidad,
    required super.precio,
    required super.importe,
    required super.estatus,
    required super.cerrado,
    required super.pedidos,
  });

  factory DetalleSesionModel.fromJson(Map<String, dynamic> json) =>
      DetalleSesionModel(
        idDetallesesion: json["id_detallesesion"],
        idSesion: json["id_sesion"],
        clave: json["clave"],
        clave2: json["clave2"],
        cantidad: json["cantidad"],
        precio: json["precio"],
        importe: json["importe"],
        estatus: json["estatus"],
        cerrado: json["cerrado"],
        pedidos: json["pedidos"],
      );

  Map<String, dynamic> toJson() => {
        "id_detallesesion": idDetallesesion,
        "id_sesion": idSesion,
        "clave": clave,
        "clave2": clave2,
        "cantidad": cantidad,
        "precio": precio,
        "importe": importe,
        "estatus": estatus,
        "cerrado": cerrado,
        "pedidos": pedidos,
      };

  @override
  DetalleSesionEntity toEntity() => DetalleSesionEntity(
        idDetallesesion: idDetallesesion,
        idSesion: idSesion,
        clave: clave,
        clave2: clave2,
        cantidad: cantidad,
        precio: precio,
        importe: importe,
        estatus: estatus,
        cerrado: cerrado,
        pedidos: pedidos,
      );
}
