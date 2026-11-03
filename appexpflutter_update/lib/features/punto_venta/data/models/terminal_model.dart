class TerminalModel {
  final String id;
  final String nombre;
  final String? banco;
  final String? cuenta;

  TerminalModel({
    required this.id,
    required this.nombre,
    this.banco,
    this.cuenta,
  });

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      id: json['terminal']?.toString() ?? '',
      nombre: json['terminal']?.toString() ?? 'Sin Nombre',
      banco: json['banco']?.toString(),
      cuenta: json['cuenta']?.toString(),
    );
  }
}
