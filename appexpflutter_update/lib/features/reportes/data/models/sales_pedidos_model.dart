import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';

class SalesPedidosModel extends SalesPedidosEntity
    with EntityConvertible<SalesPedidosModel, SalesPedidosEntity> {
  const SalesPedidosModel({
    required super.gtotal,
    required super.fecham,
  });

  factory SalesPedidosModel.fromJson(Map<String, dynamic> json) =>
      SalesPedidosModel(
        gtotal: json["gtotal"],
        fecham: json["fecham"],
      );

  @override
  SalesPedidosEntity toEntity() => SalesPedidosEntity(
        gtotal: gtotal,
        fecham: fecham,
      );
}
