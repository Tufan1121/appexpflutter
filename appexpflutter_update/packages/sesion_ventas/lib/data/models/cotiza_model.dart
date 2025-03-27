import 'package:sesion_ventas/domain/entities/cotiza_entity.dart';

class CotizaModel extends CotizaEntity{
  const CotizaModel({
    required super.idCotiza,
    required super.pedidos,
    required super.idExpo,
  });

  factory CotizaModel.fromJson(Map<String, dynamic> json) => CotizaModel(
        idCotiza: json["id_cotiza"],
        pedidos: json["pedidos"],
        idExpo: json["id_expo"],
      );

  Map<String, dynamic> toJson() => {
        "id_cotiza": idCotiza,
        "pedidos": pedidos,
        "id_expo": idExpo,
      };

  CotizaEntity toEntity() => CotizaEntity(
        idCotiza: idCotiza,
        pedidos: pedidos,
        idExpo: idExpo,
      );
}
