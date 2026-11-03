import 'package:galeria/domain/entities/galeria_entity.dart';

class GaleriaModel extends GaleriaEntity {
  const GaleriaModel({
    required super.descripcio,
    required super.pathima1,
    required super.pathima2,
    super.composicion,
    super.origen,
  });

  factory GaleriaModel.fromJson(Map<String, dynamic> json) {
    return GaleriaModel(
      descripcio: json['descripcio'],
      pathima1: json['pathima1'],
      pathima2: json['pathima2'],
      composicion: (json['composicion'] ?? '').toString().trim(),
      origen: (json['origen'] ?? '').toString().trim(),
    );
  }

  GaleriaEntity toEntity() => GaleriaEntity(
        descripcio: descripcio,
        pathima1: pathima1,
        pathima2: pathima2,
        composicion: composicion,
        origen: origen,
      );
}
