

import 'package:login/domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.accessToken,
    required super.tokenType,
    required super.nombre,
    required super.digsig,
    required super.regg,
    required super.movil,
  });

    factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        nombre: json["nombre"],
        digsig: json["digsig"],
        regg: json["regg"],
        movil: json["movil"],
    );

    Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "nombre": nombre,
        "digsig": digsig,
        "regg": regg,
        "movil": movil,
    };

  AuthUserEntity toEntity() => AuthUserEntity(
        accessToken: accessToken,
        tokenType: tokenType,
        nombre: nombre,
        digsig: digsig,
        regg: regg,
        movil: movil,
      );
}
