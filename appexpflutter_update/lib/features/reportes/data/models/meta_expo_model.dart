import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';

class MetaExpoModel extends MetaExpoEntity
    with EntityConvertible<MetaExpoModel, MetaExpoEntity> {
  const MetaExpoModel({
    required super.meta,
    required super.alcanzado,
    required super.pedidos,
    required super.puntoventa,
    required super.falta,
    required super.porcentaje,
  });

  factory MetaExpoModel.fromJson(Map<String, dynamic> json) => MetaExpoModel(
        meta: (json["meta"] as num?)?.toDouble() ?? 0,
        alcanzado: (json["alcanzado"] as num?)?.toDouble() ?? 0,
        pedidos: (json["pedidos"] as num?)?.toDouble() ?? 0,
        puntoventa: (json["puntoventa"] as num?)?.toDouble() ?? 0,
        falta: (json["falta"] as num?)?.toDouble() ?? 0,
        porcentaje: (json["porcentaje"] as num?)?.toDouble() ?? 0,
      );

  @override
  MetaExpoEntity toEntity() => MetaExpoEntity(
        meta: meta,
        alcanzado: alcanzado,
        pedidos: pedidos,
        puntoventa: puntoventa,
        falta: falta,
        porcentaje: porcentaje,
      );
}
