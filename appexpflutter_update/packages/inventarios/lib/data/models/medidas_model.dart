
import 'package:inventarios/domain/entities/medidas_entity_inv.dart';

class MedidasModelInv extends MedidasEntityInv {
 const MedidasModelInv({
    required super.medida,
    required super.largo,
    required super.ancho,
    required super.cm,
  });

  factory MedidasModelInv.fromJson(Map<String, dynamic> json) {
    return MedidasModelInv(
      medida: json['MEDIDA'],
      largo: json['LARGO'],
      ancho: json['ANCHO'],
      cm: json['CM'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MEDIDA': medida,
      'LARGO': largo,
      'ANCHO': ancho,
      'CM': cm,
    };
  }

  MedidasEntityInv toEntity() => MedidasEntityInv(
        medida: medida,
        largo: largo,
        ancho: ancho,
        cm: cm,
      );
}

List<MedidasModelInv> parseMedidas(List<dynamic> jsonList) {
  return jsonList.map((json) => MedidasModelInv.fromJson(json)).toList();
}
