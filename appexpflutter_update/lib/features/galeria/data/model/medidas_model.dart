import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/medidas_entity.dart';

class MedidasModel extends MedidasEntity
    with EntityConvertible<MedidasModel, MedidasEntity> {
  const MedidasModel({
    required super.medidas,
    required super.precio,
  });

  factory MedidasModel.fromJson(Map<String, dynamic> json) {
    return MedidasModel(
      medidas: json['medidas'],
      precio: json['precio'],
    );
  }


  @override
  MedidasEntity toEntity() => MedidasEntity(
        medidas: medidas,
        precio: precio,
      );
}
