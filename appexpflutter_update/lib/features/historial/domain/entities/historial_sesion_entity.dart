import 'package:equatable/equatable.dart';

class HistorialSesionEntity extends Equatable {
  final int idSesion;
  final int idCliente;
  final DateTime fecha;
  final int? idMetodoPago;
  final int? idMetodoPago2;
  final int? idMetodoPago3;
  final String? observaciones;
  final String usuario;
  final String pedidos;
  final int idExpo;
  final int estatus;
  final int? anticipo;
  final int? anticipo2;
  final int? anticipo3;
  final int totalPagar;
  final int? entregado;
  final double saldo;
  final String? dig1;
  final String? dig2;
  final String? dig3;
  final String? ticket;
  final String? nomCliente;
  final String nombre;
  final String apellido;
  final String telefono;

  const HistorialSesionEntity({
    required this.idSesion,
    required this.idCliente,
    required this.fecha,
    this.idMetodoPago,
    this.idMetodoPago2,
    this.idMetodoPago3,
    this.observaciones,
    required this.usuario,
    required this.pedidos,
    required this.idExpo,
    required this.estatus,
    this.anticipo,
    this.anticipo2,
    this.anticipo3,
    required this.totalPagar,
    this.entregado,
    required this.saldo,
    this.dig1,
    this.dig2,
    this.dig3,
    required this.ticket,
    this.nomCliente,
    required this.nombre,
    required this.apellido,
    required this.telefono,
  });

  @override
  List<Object?> get props => [
        idSesion,
        idCliente,
        fecha,
        idMetodoPago,
        idMetodoPago2,
        idMetodoPago3,
        observaciones,
        usuario,
        pedidos,
        idExpo,
        estatus,
        anticipo,
        anticipo2,
        anticipo3,
        totalPagar,
        entregado,
        saldo,
        dig1,
        dig2,
        dig3,
        ticket,
        nomCliente,
        nombre,
        apellido
      ];
}