import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_sesion_entity.dart';

class HistorialSesionModel extends HistorialSesionEntity
    with EntityConvertible<HistorialSesionModel, HistorialSesionEntity> {
  const HistorialSesionModel({
    required super.idSesion,
    required super.idCliente,
    required super.fecha,
    super.idMetodoPago,
    super.idMetodoPago2,
    super.idMetodoPago3,
    super.observaciones,
    required super.usuario,
    required super.pedidos,
    required super.idExpo,
    required super.estatus,
    super.anticipo,
    super.anticipo2,
    super.anticipo3,
    required super.totalPagar,
    super.entregado,
    required super.saldo,
    super.dig1,
    super.dig2,
    super.dig3,
    super.ticket,
    super.nomCliente,
    required super.nombre,
    required super.apellido,
    required super.telefono,

  });

  factory HistorialSesionModel.fromJson(Map<String, dynamic> json) =>
      HistorialSesionModel(
        idSesion: json['id_sesion'],
        idCliente: json['id_cliente'],
        fecha: DateTime.parse(json['fecha']),
        idMetodoPago: json['id_metodopago'],
        idMetodoPago2: json['id_metodopago2'],
        idMetodoPago3: json['id_metodopago3'],
        observaciones: json['observaciones'],
        usuario: json['usuario'],
        pedidos: json['pedidos'],
        idExpo: json['id_expo'],
        estatus: json['estatus'],
        anticipo: json['anticipo'],
        anticipo2: json['anticipo2'],
        anticipo3: json['anticipo3'],
        totalPagar: json['total_pagar'],
        entregado: json['entregado'],
        saldo: (json['saldo'] as num).toDouble(),
        dig1: json['dig1']?.toString(),
        dig2: json['dig2']?.toString(),
        dig3: json['dig3']?.toString(),
        ticket: json['ticket'],
        nomCliente: json['nomcliente'],
        nombre: json['nombre'],
        apellido: json['apellido'],
        telefono: json['telefono'],
      );

  Map<String, dynamic> toJson() => {
        'id_sesion': idSesion,
        'id_cliente': idCliente,
        'fecha': fecha.toIso8601String(),
        'id_metodopago': idMetodoPago,
        'id_metodopago2': idMetodoPago2,
        'id_metodopago3': idMetodoPago3,
        'observaciones': observaciones,
        'usuario': usuario,
        'pedidos': pedidos,
        'id_expo': idExpo,
        'estatus': estatus,
        'anticipo': anticipo,
        'anticipo2': anticipo2,
        'anticipo3': anticipo3,
        'total_pagar': totalPagar,
        'entregado': entregado,
        'saldo': saldo,
        'dig1': dig1,
        'dig2': dig2,
        'dig3': dig3,
        'ticket': ticket,
        'nomcliente': nomCliente,
        'nombre': nombre,
        'apellido': apellido,
      };

  @override
  HistorialSesionEntity toEntity() => HistorialSesionEntity(
        idSesion: idSesion,
        idCliente: idCliente,
        fecha: fecha,
        idMetodoPago: idMetodoPago,
        idMetodoPago2: idMetodoPago2,
        idMetodoPago3: idMetodoPago3,
        observaciones: observaciones,
        usuario: usuario,
        pedidos: pedidos,
        idExpo: idExpo,
        estatus: estatus,
        anticipo: anticipo,
        anticipo2: anticipo2,
        anticipo3: anticipo3,
        totalPagar: totalPagar,
        entregado: entregado,
        saldo: saldo,
        dig1: dig1,
        dig2: dig2,
        dig3: dig3,
        ticket: ticket,
        nomCliente: nomCliente,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );
}
