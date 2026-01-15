class CuentaModel {
  final String id;
  final String nombre;

  CuentaModel({required this.id, required this.nombre});

  factory CuentaModel.fromJson(Map<String, dynamic> json) {
    return CuentaModel(
      // 'cuenta' comes as int or string, safe to convert to String for ID
      id: json['cuenta']?.toString() ?? '',
      nombre: '${json['banco'] ?? ''} - ${json['cuenta'] ?? ''}',
    );
  }
}
