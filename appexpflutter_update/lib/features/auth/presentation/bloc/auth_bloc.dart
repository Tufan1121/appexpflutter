import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:appexpflutter_update/features/auth/domain/usecases/auth_usecase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;
  final storage = const FlutterSecureStorage();

  AuthBloc({required this.authUsecase}) : super(AuthInitial()) {
    on<LoginEvent>(_getToken);
    on<LogoutEvent>(_deleteAccessToken);
    on<DemoLoginEvent>(_demoLogin);
  }

  Future<void> _demoLogin(DemoLoginEvent event, Emitter<AuthState> emit) async {
     final prefs = await SharedPreferences.getInstance();
     emit(AuthLoading());
     
     // Hardcoded values from the specific demo token payload
     const username = "Helmut Heise";
     const movil = "";
     const almacen = "EXPOS GDL";
     const digsig = "208";

     await storage.write(key: 'accessToken', value: event.token);
     await prefs.setString('username', username);
     await prefs.setString('movil', movil);
     await prefs.setString('almacen', almacen);
     await prefs.setString('digsig', digsig);
     
     emit(const AuthAuthenticated(username: username));
  }

  Future<void> _getToken(LoginEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    emit(AuthLoading());
    final result = await authUsecase.login(event.email, event.password);
    await result.fold((error) async => emit(AuthError(message: error.message)),
        (user) async {
      // Guarda el accessToken en el almacenamiento seguro
      await storage.write(key: 'accessToken', value: user.accessToken);
      await prefs.setString('username', user.nombre);
      await prefs.setString('movil', user.movil);
      await prefs.setString('almacen', user.descripcio);
      await prefs.setString('digsig', user.digsig);
      emit(AuthAuthenticated(username: user.nombre));
    });
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
