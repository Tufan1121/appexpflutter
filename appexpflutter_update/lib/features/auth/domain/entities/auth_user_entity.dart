import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String accessToken;
  final String tokenType;
  final String nombre;
  final String digsig;
  final int regg;

  const AuthUserEntity({
    required this.accessToken,
    required this.tokenType,
    required this.nombre,
    required this.digsig,
    required this.regg,
  });

  @override
  List<Object> get props => [accessToken, tokenType, nombre, digsig, regg];
}
