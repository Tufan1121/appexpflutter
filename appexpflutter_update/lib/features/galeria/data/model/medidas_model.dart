import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/medidas_entity.dart';

class MedidasModel extends MedidasEntity
    with EntityConvertible<MedidasModel, MedidasEntity> {
  const MedidasModel({
    required super.medidas,
  });

  factory MedidasModel.fromJson(Map<String, dynamic> json) {
    return MedidasModel(
      medidas: json['medidas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medidas': medidas,
    };
  }

  @override
  MedidasEntity toEntity() => MedidasEntity(
        medidas: medidas,
      );
}
