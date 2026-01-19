class CuentaModel {
  final String id;
  final String nombre;
  final String banco;
  final String cuenta;
  final String? dig;

  CuentaModel({
    required this.id,
    required this.nombre,
    required this.banco,
    required this.cuenta,
    this.dig,
  });

  factory CuentaModel.fromJson(Map<String, dynamic> json) {
    final banco = json['banco']?.toString() ?? '';
    final cuenta = json['cuenta']?.toString() ?? '';
    
    return CuentaModel(
      id: cuenta,
      nombre: '$banco - $cuenta',
      banco: banco,
      cuenta: cuenta,
      dig: json['dig']?.toString(),
    );
  }
}
