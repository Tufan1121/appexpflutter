import 'package:sesion_ventas/domain/entities/sesion_entity.dart';

class SesionModel extends SesionEntity {
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


  SesionEntity toEntity() => SesionEntity(
        idSesion: idSesion,
        pedidos: pedidos,
        idExpo: idExpo,
      );
}
