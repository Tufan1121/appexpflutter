
import 'package:galeria/domain/entities/medidas_entity.dart';

class MedidasModel extends MedidasEntity {
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


  MedidasEntity toEntity() => MedidasEntity(
        medidas: medidas,
        precio: precio,
      );
}
