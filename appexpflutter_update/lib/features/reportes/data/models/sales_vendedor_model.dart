import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';

class SalesVendedorModel extends SalesVendedorEntity
    with EntityConvertible<SalesVendedorModel, SalesVendedorEntity> {
  const SalesVendedorModel({
    required super.vendedor,
    required super.pedidos,
    required super.puntoventa,
    required super.gtotal,
  });

  factory SalesVendedorModel.fromJson(Map<String, dynamic> json) =>
      SalesVendedorModel(
        vendedor: json["vendedor"] ?? '',
        pedidos: (json["pedidos"] as num?)?.toDouble() ?? 0,
        puntoventa: (json["puntoventa"] as num?)?.toDouble() ?? 0,
        gtotal: (json["gtotal"] as num?)?.toDouble() ?? 0,
      );

  @override
  SalesVendedorEntity toEntity() => SalesVendedorEntity(
        vendedor: vendedor,
        pedidos: pedidos,
        puntoventa: puntoventa,
        gtotal: gtotal,
      );
}
