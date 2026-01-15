part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// final class AuthAuthenticated extends AuthState {
//   final String token;

//   const AuthAuthenticated({required this.token});

//   @override
//   List<Object> get props => [token];
// }
class AuthAuthenticated extends AuthState {
  final String username;
  const AuthAuthenticated({required this.username});

  @override
  List<Object> get props => [username];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
