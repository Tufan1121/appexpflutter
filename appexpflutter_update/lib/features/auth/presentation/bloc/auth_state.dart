part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

// final class AuthAuthenticated extends AuthState {
//   final String token;

//   const AuthAuthenticated({required this.token});

//   @override
//   List<Object> get props => [token];
// }
final class AuthAuthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
