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
      // Permisos del usuario para condicionar el menu principal.
      await prefs.setBool('perm_inventarios', user.permisos.inventarios);
      await prefs.setBool('perm_precios', user.permisos.precios);
      await prefs.setBool('perm_cotizaciones', user.permisos.cotizaciones);
      await prefs.setBool('perm_historial', user.permisos.historial);
      await prefs.setBool('perm_galeria', user.permisos.galeria);
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
