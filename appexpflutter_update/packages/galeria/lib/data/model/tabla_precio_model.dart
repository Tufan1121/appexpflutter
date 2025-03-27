
import 'package:galeria/domain/entities/tabla_precio_entity.dart';

class TablaPrecioModel extends TablaPreciosEntity {
  const TablaPrecioModel({
    required super.medidas,
    required super.precio1,
    required super.precio2,
    required super.precio3,
    required super.precio4,
    required super.precio5,
    required super.precio6,
    required super.precio7,
    required super.precio8,
    super.precio9,
    super.precio10,
  });

  factory TablaPrecioModel.fromJson(Map<String, dynamic> json) {
    return TablaPrecioModel(
      medidas: json['medidas'] ?? '',
      precio1: json['precio1'] ?? 0,
      precio2: json['precio2'] ?? 0,
      precio3: json['precio3'] ?? 0,
      precio4: json['precio4'] ?? 0,
      precio5: json['precio5'] ?? 0,
      precio6: json['precio6'] ?? 0,
      precio7: json['precio7'] ?? 0,
      precio8: json['precio8'] ?? 0,
      precio9: json['precio9'] ?? 0,
      precio10: json['precio10'] ?? 0,
    );
  }

  TablaPreciosEntity toEntity() => TablaPreciosEntity(
        medidas: medidas,
        precio1: precio1,
        precio2: precio2,
        precio3: precio3,
        precio4: precio4,
        precio5: precio5,
        precio6: precio6,
        precio7: precio7,
        precio8: precio8,
        precio9: precio9,
        precio10: precio10,
      );
}
