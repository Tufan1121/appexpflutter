import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login/domain/usecases/auth_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;
  final storage = const FlutterSecureStorage();

  AuthBloc({required this.authUsecase}) : super(AuthInitial()) {
    on<LoginEvent>(_getToken);
    on<LogoutEvent>(_deleteAccessToken);
    on<ForceLoginEvent>(_forceLogin);
  }

  Future<void> _getToken(LoginEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    emit(AuthLoading());
    final result = await authUsecase.login(event.email, event.password);
    
    if (result.isLeft()) {
      final error = result.getLeft().toNullable()!;
      // Detectar si es un error de sesión activa en otro dispositivo
      if (error.message.toLowerCase().contains('sesion abierta') ||
          error.message.toLowerCase().contains('sesión abierta') ||
          error.message.toLowerCase().contains('otro dispositivo')) {
        emit(AuthSessionConflict(
          email: event.email,
          password: event.password,
          message: error.message,
        ));
      } else {
        emit(AuthError(message: error.message));
      }
    } else {
      final user = result.getRight().toNullable()!;
      // Guarda el accessToken en el almacenamiento seguro
      await storage.write(key: 'accessToken', value: user.accessToken);
      await prefs.setString('username', user.nombre);
      await prefs.setString('movil', user.movil);
      await prefs.setString('almacen', user.descripcio);
      await prefs.setString('digsig', user.digsig);
      emit(AuthAuthenticated(username: user.nombre));
    }
  }

  Future<void> _forceLogin(ForceLoginEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    emit(AuthLoading());
    
    // Primero intentar cerrar la sesión existente con las credenciales
    await authUsecase.logoutByEmail(event.email, event.password);
    
    // Ahora intentar hacer login
    final result = await authUsecase.login(event.email, event.password);
    
    if (result.isLeft()) {
      final error = result.getLeft().toNullable()!;
      emit(AuthError(message: error.message));
    } else {
      final user = result.getRight().toNullable()!;
      await storage.write(key: 'accessToken', value: user.accessToken);
      await prefs.setString('username', user.nombre);
      await prefs.setString('movil', user.movil);
      await prefs.setString('almacen', user.descripcio);
      await prefs.setString('digsig', user.digsig);
      emit(AuthAuthenticated(username: user.nombre));
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  // Método para eliminar el token almacenado (logout)
  Future<void> _deleteAccessToken(
      LogoutEvent event, Emitter<AuthState> emit) async {
    final result = await authUsecase.logout();
    await result.fold((error) async {
      await storage.delete(key: 'accessToken');
    }, (message) async {
      await storage.delete(key: 'accessToken');
    });
  }
}
