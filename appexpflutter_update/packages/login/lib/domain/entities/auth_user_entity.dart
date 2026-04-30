import 'package:equatable/equatable.dart';
import 'package:login/domain/entities/permisos_entity.dart';

class AuthUserEntity extends Equatable {
  final String accessToken;
  final String tokenType;
  final String nombre;
  final String digsig;
  final int regg;
  final String movil;
  final String descripcio;
  final PermisosEntity permisos;

  const AuthUserEntity({
    required this.accessToken,
    required this.tokenType,
    required this.nombre,
    required this.digsig,
    required this.regg,
    required this.movil,
    required this.descripcio,
    required this.permisos,
  });

  @override
  List<Object> get props => [
        accessToken,
        tokenType,
        nombre,
        digsig,
        regg,
        movil,
        descripcio,
        permisos,
      ];
}
