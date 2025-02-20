import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';

class SalesTicketsModel extends SalesTicketsEntity
    with EntityConvertible<SalesTicketsModel, SalesTicketsEntity> {
  const SalesTicketsModel({
    required super.gtotal,
    required super.fecham,
  });

  factory SalesTicketsModel.fromJson(Map<String, dynamic> json) =>
      SalesTicketsModel(
        gtotal: (json["gtotal"] as num).toDouble(),
        fecham: json["fecham"],
      );

  @override
  SalesTicketsEntity toEntity() => SalesTicketsEntity(
        gtotal: (gtotal),
        fecham: fecham,
      );
}
