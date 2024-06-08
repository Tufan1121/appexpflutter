import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:appexpflutter_update/features/auth/domain/usecases/auth_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;
  AuthBloc({required this.authUsecase}) : super(AuthInitial()) {
    on<LoginEvent>(_getToken);
  }

  Future<void> _getToken(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authUsecase.login(event.email, event.password);
    result.fold(
      (error) => emit(AuthError(message: error.message)),
      (token) => emit(AuthAuthenticated(token: token)),
    );
  }
}
