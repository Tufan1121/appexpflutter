

import 'package:galeria/domain/entities/galeria_entity.dart';

class GaleriaModel extends GaleriaEntity {
  const GaleriaModel({
    required super.descripcio,
    required super.pathima1,
    required super.pathima2,
  });

  factory GaleriaModel.fromJson(Map<String, dynamic> json) {
    return GaleriaModel(
      descripcio: json['descripcio'],
      pathima1: json['pathima1'],
      pathima2: json['pathima2'],
    );
  }

  GaleriaEntity toEntity() => GaleriaEntity(
        descripcio: descripcio,
        pathima1: pathima1,
        pathima2: pathima2,
      );
}
