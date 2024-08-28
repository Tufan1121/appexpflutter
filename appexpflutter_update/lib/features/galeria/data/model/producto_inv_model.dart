import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/producto_inv_entity.dart';

class ProductoInvModel extends ProductoInvEntity
    with EntityConvertible<ProductoInvModel, ProductoInvEntity> {
  const ProductoInvModel({
    required super.medidas,
    required super.hm,
    required super.desalmacen,
  });

  factory ProductoInvModel.fromJson(Map<String, dynamic> json) {
    return ProductoInvModel(
      medidas: json['medidas'] ?? '',
      hm: json['hm'] ?? 0,
      desalmacen: json['desalmacen'] ?? '',
    );
  }

  @override
  ProductoInvEntity toEntity() => ProductoInvEntity(
        medidas: medidas,
        hm: hm,
        desalmacen: desalmacen,
      );
}
