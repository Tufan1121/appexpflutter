

import 'package:login/domain/entities/auth_user_entity.dart';
import 'package:login/domain/entities/permisos_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.accessToken,
    required super.tokenType,
    required super.nombre,
    required super.digsig,
    required super.regg,
    required super.movil,
    required super.descripcio,
    required super.permisos,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        nombre: json["nombre"],
        digsig: json["digsig"],
        regg: json["regg"],
        movil: json["movil"],
        descripcio: json["descripcio"],
        permisos: _permisosFromJson(json["permisos"]),
      );

  static PermisosEntity _permisosFromJson(dynamic raw) {
    // Si el backend (version vieja) no manda el bloque, caemos al default
    // restringido: solo inventarios.
    if (raw is! Map) return const PermisosEntity.restringido();
    final map = Map<String, dynamic>.from(raw);
    return PermisosEntity(
      inventarios: map["inventarios"] == true,
      precios: map["precios"] == true,
      cotizaciones: map["cotizaciones"] == true,
      historial: map["historial"] == true,
      galeria: map["galeria"] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "nombre": nombre,
        "digsig": digsig,
        "regg": regg,
        "movil": movil,
        "descripcio": descripcio,
        "permisos": {
          "inventarios": permisos.inventarios,
          "precios": permisos.precios,
          "cotizaciones": permisos.cotizaciones,
          "historial": permisos.historial,
          "galeria": permisos.galeria,
        },
      };

  AuthUserEntity toEntity() => AuthUserEntity(
        accessToken: accessToken,
        tokenType: tokenType,
        nombre: nombre,
        digsig: digsig,
        regg: regg,
        movil: movil,
        descripcio: descripcio,
        permisos: permisos,
      );
}
