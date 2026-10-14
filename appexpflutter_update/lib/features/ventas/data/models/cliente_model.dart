import 'package:api_client/exceptions/custom_exceptions/not_found_expection.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/cliente_entity.dart';

import '../../../../config/mappers/entity_convertable.dart';

class ClienteModel extends ClienteEntity
    with EntityConvertible<ClienteModel, ClienteEntity> {
  ClienteModel({
    required super.idCliente,
    required super.nombre,
    required super.apellido,
    super.direccion,
    required super.telefono,
    super.ladaPais,
    required super.correo,
    super.rfc,
    // super.tipoPersona,
    // super.usoCfdi,
    // super.empresa,
    required super.factura,
    // super.cp,
    // required super.usuario,
    // required super.fecha,
    // required super.idExpo,
    // super.cliente,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    try {
      return ClienteModel(
        idCliente: json["id_cliente"] as int,
        nombre: json["nombre"] as String,
        apellido: json["apellido"] as String,
        direccion: json["direccion"] as String?,
        telefono: json["telefono"] as String,
        // Sin la columna (o vacía) el cliente se toma como de México
        ladaPais: (json["lada_pais"] ?? '').toString().trim().isEmpty
            ? '52'
            : json["lada_pais"].toString().trim(),
        correo: json["correo"] as String,
        rfc: json["rfc"] as String?,
        // tipoPersona: json["tipopersona"] as String?,
        // usoCfdi: json["usocfdi"] as String?,
        // empresa: json["empresa"] as String?,
        factura: json["factura"] as int,
        // cp: json["cp"] as String?,
        // usuario: json["usuario"] as String,
        // fecha: DateTime.parse(json["fecha"]),
        // idExpo: json["id_expo"] as int,
        // cliente: json["cliente"] as String?,
      );
    } catch (e) {
      throw NotFoundException('Error parsing JSON to ClienteModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cliente': idCliente,
      'nombre': nombre,
      'apellido': apellido,
      'direccion': direccion,
      'telefono': telefono,
      'lada_pais': ladaPais,
      'correo': correo,
      //   'rfc': rfc,
      //   'tipopersona': tipoPersona,
      //   'usocfdi': usoCfdi,
      //   'empresa': empresa,
      'factura': factura,
      //   'cp': cp,
      //   'usuario': usuario,
      // 'fecha': fecha.toIso8601String(),
      //   'id_expo': idExpo,
      //   'cliente': cliente,
    };
  }

  @override
  ClienteEntity toEntity() => ClienteEntity(
        idCliente: idCliente,
        nombre: nombre,
        apellido: apellido,
        direccion: direccion,
        telefono: telefono,
        ladaPais: ladaPais,
        correo: correo,
        rfc: rfc,
        // tipoPersona: tipoPersona,
        // usoCfdi: usoCfdi,
        // empresa: empresa,
        factura: factura,
        // cp: cp,
        // usuario: usuario,
        // fecha: fecha,
        // idExpo: idExpo,
        // cliente: cliente,
      );
}
