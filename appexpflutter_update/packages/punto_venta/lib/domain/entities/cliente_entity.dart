import 'package:equatable/equatable.dart';

class ClienteEntity extends Equatable {
  final int idCliente;
  final String nombre;
  final String apellido;
  final String? direccion;
  final String telefono;
  final String correo;
  final String? rfc;
  // final String? tipoPersona;
  // final String? usoCfdi;
  // final String? empresa;
  final int factura;
  // final String? cp;
  // final String usuario;
  // final DateTime fecha;
  // final int idExpo;
  // final String? cliente;

  const ClienteEntity({
    required this.idCliente,
    required this.nombre,
    required this.apellido,
    this.direccion,
    required this.telefono,
    required this.correo,
    this.rfc,
    // this.tipoPersona,
    // this.usoCfdi,
    // this.empresa,
    required this.factura,
    // this.cp,
    // required this.usuario,
    // required this.fecha,
    // required this.idExpo,
    // this.cliente,
  });

  @override
  List<Object?> get props => [
        idCliente,
        nombre,
        apellido,
        direccion,
        telefono,
        correo,
        rfc,
        // tipoPersona,
        // usoCfdi,
        // empresa,
        factura,
        // cp,
        // usuario,
        // fecha,
        // idExpo,
        // cliente
      ];
}
