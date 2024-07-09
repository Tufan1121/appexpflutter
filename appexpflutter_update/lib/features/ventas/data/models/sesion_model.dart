import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/sesion_entity.dart';

class SesionModel extends SesionEntity
    with EntityConvertible<SesionModel, SesionEntity> {
  const SesionModel({
    required super.idSesion,
    required super.pedidos,
    required super.idExpo,
  });

  factory SesionModel.fromJson(Map<String, dynamic> json) => SesionModel(
        idSesion: json["id_sesion"],
        pedidos: json["pedidos"],
        idExpo: json["id_expo"],
      );

  Map<String, dynamic> toJson() => {
        "id_sesion": idSesion,
        "pedidos": pedidos,
        "id_expo": idExpo,
      };

  @override
  SesionEntity toEntity() => SesionEntity(
        idSesion: idSesion,
        pedidos: pedidos,
        idExpo: idExpo,
      );
}
