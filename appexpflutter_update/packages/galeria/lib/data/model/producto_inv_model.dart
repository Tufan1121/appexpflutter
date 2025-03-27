
import 'package:galeria/domain/entities/producto_inv_entity.dart';

class ProductoInvModel extends ProductoInvEntity{
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
  
  ProductoInvEntity toEntity() => ProductoInvEntity(
        medidas: medidas,
        hm: hm,
        desalmacen: desalmacen,
      );
}
