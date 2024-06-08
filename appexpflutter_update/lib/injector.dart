part of 'main.dart';

final injector = GetIt.instance;

Future<void> init() async {
  injector
    //* Network
    ..registerLazySingleton<DioClient>(DioClient.new)

    //* Data Sources
    ..registerLazySingleton<AuthDatasource>(
        () => AuthDataSourceImpl(dioClient: injector()))

    //* Repositories
    ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(authDatasource: injector()))

    //* Usecases
    ..registerLazySingleton<AuthUsecase>(
        () => AuthUsecase(authRepository: injector()))

    //* Blocs
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(authUsecase: injector()));
}
