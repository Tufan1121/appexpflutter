class CuentaModel {
  final String id;
  final String nombre;
  final String banco;
  final String cuenta;
  final String? clabe;

  CuentaModel({
    required this.id,
    required this.nombre,
    required this.banco,
    required this.cuenta,
    this.clabe,
  });

  factory CuentaModel.fromJson(Map<String, dynamic> json) {
    final banco = json['banco']?.toString() ?? '';
    final cuenta = json['cuenta']?.toString() ?? '';
    final clabe = json['clabe']?.toString();
    
    return CuentaModel(
      id: cuenta,
      nombre: '$banco - $cuenta',
      banco: banco,
      cuenta: cuenta,
      clabe: clabe,
    );
  }
}
