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
    ..registerLazySingleton<PedidoDataSource>(
        () => PedidoDataSourceImpl(dioClient: injector()))
    ..registerLazySingleton<InventarioExpoDataSource>(
        () => InventarioExpoDataSourceImpl(dioClient: injector()))
    ..registerLazySingleton<HistorialDataSource>(
        () => HistorialDataSourceImpl(dioclient: injector()))

    //* Repositories
    ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(authDatasource: injector()))
    ..registerLazySingleton<ProductoRepository>(
        () => ProductoRepositoryImpl(productoDataSource: injector()))
    ..registerLazySingleton<ClienteRepository>(
        () => ClienteRepositoryImpl(clienteDataSource: injector()))
    ..registerLazySingleton<PedidoRepository>(
        () => PedidoRepositoryImpl(pedidoDataSource: injector()))
    ..registerLazySingleton<InventarioExpoRepository>(() =>
        InventarioExpoRepositoryImpl(inventarioExpoDataSource: injector()))
    ..registerLazySingleton<HistorialRepository>(
        () => HistorialRepositoryImpl(historialDataSource: injector()))

    //* Usecases
    ..registerLazySingleton<AuthUsecase>(
        () => AuthUsecase(authRepository: injector()))
    ..registerLazySingleton<ProductoUsecase>(
        () => ProductoUsecase(productoRepository: injector()))
    ..registerLazySingleton<ClienteUsecase>(
        () => ClienteUsecase(clienteRepository: injector()))
    ..registerLazySingleton<PedidoUsecase>(
        () => PedidoUsecase(pedidoRepository: injector()))
    ..registerLazySingleton<InventarioExpoUsecase>(
        () => InventarioExpoUsecase(inventarioExpoRepository: injector()))
    ..registerLazySingleton<HistorialUsecase>(
        () => HistorialUsecase(historialRepository: injector()))

    //* Blocs
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(authUsecase: injector()))
    ..registerLazySingleton<PreciosBloc>(
        () => PreciosBloc(productoUsecase: injector()))
    ..registerLazySingleton<ProductosBloc>(
        () => ProductosBloc(productoUsecase: injector()))
    ..registerLazySingleton<ClienteBloc>(
        () => ClienteBloc(clienteUsecase: injector()))
    ..registerLazySingleton<InventarioBloc>(
        () => InventarioBloc(productoUsecase: injector()))
    ..registerLazySingleton<InventarioBodegaBloc>(
        () => InventarioBodegaBloc(productoUsecase: injector()))
    ..registerLazySingleton<InventarioExpoBloc>(
        () => InventarioExpoBloc(productoUsecase: injector()))
    ..registerLazySingleton<BusquedaGlobalBloc>(
        () => BusquedaGlobalBloc(productoUsecase: injector()))
    ..registerLazySingleton<SesionPedidoBloc>(
        () => SesionPedidoBloc(pedidoUsecase: injector()))
    ..registerLazySingleton<CotizaPedidoBloc>(
        () => CotizaPedidoBloc(pedidoUsecase: injector()))
    ..registerLazySingleton<HistorialBloc>(
        () => HistorialBloc(historialUsecase: injector()))
    ..registerLazySingleton<PedidoBloc>(
        () => PedidoBloc(pedidoUsecase: injector()));
}
