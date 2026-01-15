class TerminalModel {
  final String id;
  final String nombre;

  TerminalModel({required this.id, required this.nombre});

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      id: json['terminal']?.toString() ?? '',
      nombre: json['terminal']?.toString() ?? 'Sin Nombre',
    );
  }
}
