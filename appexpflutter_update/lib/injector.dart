part of 'main.dart';

final injector = GetIt.instance;

Future<void> init() async {
  injector
    //* Network
    ..registerLazySingleton<DioClient>(DioClient.new)

    //* Data Sources
    ..registerLazySingleton<AuthDatasource>(
        () => AuthDataSourceImpl(dioClient: injector()))
    ..registerLazySingleton<ProductoDataSource>(
        () => ProductoDataSourceImpl(dioClient: injector()))
    ..registerLazySingleton<ClienteDataSource>(
        () => ClienteDataSourceImpl(dioClient: injector()))

    //* Repositories
    ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(authDatasource: injector()))
    ..registerLazySingleton<ProductoRepository>(
        () => ProductoRepositoryImpl(productoDataSource: injector()))
    ..registerLazySingleton<ClienteRepository>(
        () => ClienteRepositoryImpl(clienteDataSource: injector()))

    //* Usecases
    ..registerLazySingleton<AuthUsecase>(
        () => AuthUsecase(authRepository: injector()))
    ..registerLazySingleton<ProductoUsecase>(
        () => ProductoUsecase(productoRepository: injector()))
    ..registerLazySingleton<ClienteUsecase>(
        () => ClienteUsecase(clienteRepository: injector()))

    //* Blocs
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(authUsecase: injector()))
    ..registerLazySingleton<PreciosBloc>(
        () => PreciosBloc(productoUsecase: injector()))
    ..registerLazySingleton<ProductosBloc>(
        () => ProductosBloc(productoUsecase: injector()))
    ..registerLazySingleton<ClienteBloc>(
        () => ClienteBloc(clienteUsecase: injector()));
}
