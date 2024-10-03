import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/tickets_entity.dart';

class TicketsModel extends TicketsEntity
    with EntityConvertible<TicketsModel, TicketsEntity> {
  const TicketsModel({
    required super.documen,
    required super.fechaEmi,
    required super.descripcio,
    required super.vendedor,
    required super.crea,
    required super.factura,
    required super.rfc,
    super.telefono,
    super.direccion,
    required super.total,
    required super.fecham,
  });

  factory TicketsModel.fromJson(Map<String, dynamic> json) => TicketsModel(
        documen: json["documen"],
        fechaEmi: json["fecha_emi"],
        descripcio: json["descripcio"],
        vendedor: json["vendedor"],
        crea: DateTime.parse(json["crea"]),
        factura: json["factura"],
        rfc: json["rfc"],
        telefono: json["telefono"],
        direccion: json["direccion"],
        total: json["total"].toDouble(),
        fecham: json["fecham"],
      );

  @override
  TicketsEntity toEntity() => TicketsEntity(
        documen: documen,
        fechaEmi: fechaEmi,
        descripcio: descripcio,
        vendedor: vendedor,
        crea: crea,
        factura: factura,
        rfc: rfc,
        telefono: telefono,
        direccion: direccion,
        total: total,
        fecham: fecham,
      );
}
