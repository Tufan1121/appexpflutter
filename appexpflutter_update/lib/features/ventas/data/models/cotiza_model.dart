import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cotiza_entity.dart';

class CotizaModel extends CotizaEntity
    with EntityConvertible<CotizaModel, CotizaEntity> {
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

  @override
  CotizaEntity toEntity() => CotizaEntity(
        idCotiza: idCotiza,
        pedidos: pedidos,
        idExpo: idExpo,
      );
}
