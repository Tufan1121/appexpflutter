import 'package:equatable/equatable.dart';

class TicketsEntity extends Equatable {
  final String documen;
  final String fechaEmi;
  final String descripcio;
  final String vendedor;
  final DateTime crea;
  final String? factura;
  final String? rfc;
  final String? telefono;
  final String? direccion;
  final double total;
  final String fecham;

  const TicketsEntity({
    required this.documen,
    required this.fechaEmi,
    required this.descripcio,
    required this.vendedor,
    required this.crea,
    required this.factura,
    required this.rfc,
    this.telefono,
    this.direccion,
    required this.total,
    required this.fecham,
  });

  @override
  List<Object?> get props => [
        documen,
        fechaEmi,
        descripcio,
        vendedor,
        crea,
        factura,
        rfc,
        telefono,
        direccion,
        total,
        fecham
      ];
}
