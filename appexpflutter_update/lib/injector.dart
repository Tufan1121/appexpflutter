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
    ..registerLazySingleton<PedidoDataVentaSource>(
        () => PedidoDataVentaSourceImpl(dioClient: injector()))
    ..registerLazySingleton<InventarioExpoVentaDataSource>(
        () => InventarioExpoVentaDataSourceImpl(dioClient: injector()))
    ..registerLazySingleton<InventarioExpoDataSource>(
        () => InventarioExpoDataSourceImpl(dioClient: injector()))
    ..registerLazySingleton<HistorialDataSource>(
        () => HistorialDataSourceImpl(dioclient: injector()))
    ..registerLazySingleton<GaleriaDataSource>(
        () => GaleriaDataSourceImpl(dioClient: injector()))
    ..registerLazySingleton<ConsultaDatasource>(
        () => ConsultaDatasourceImp(dioClient: injector()))

    //* Repositories
    ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(authDatasource: injector()))
    ..registerLazySingleton<ProductoRepository>(
        () => ProductoRepositoryImpl(productoDataSource: injector()))
    ..registerLazySingleton<ClienteRepository>(
        () => ClienteRepositoryImpl(clienteDataSource: injector()))
    ..registerLazySingleton<PedidoRepository>(
        () => PedidoRepositoryImpl(pedidoDataSource: injector()))
    ..registerLazySingleton<PedidoVentaRepository>(
        () => PedidoVentaRepositoryImpl(pedidoDataSource: injector()))
    ..registerLazySingleton<InventarioExpoVentaRepository>(() =>
        InventarioExpoVentaRepositoryImpl(inventarioExpoDataSource: injector()))
    ..registerLazySingleton<InventarioExpoRepository>(() =>
        InventarioExpoRepositoryImpl(inventarioExpoDataSource: injector()))
    ..registerLazySingleton<HistorialRepository>(
        () => HistorialRepositoryImpl(historialDataSource: injector()))
    ..registerLazySingleton<GaleriaRepository>(
        () => GaleriaRepositoryImpl(galeriaDataSource: injector()))
    ..registerLazySingleton<TicketsRepository>(
        () => TicketsRepositoryImpl(ticketsDataSource: injector()))

    //* Usecases
    ..registerLazySingleton<AuthUsecase>(
        () => AuthUsecase(authRepository: injector()))
    ..registerLazySingleton<ProductoUsecase>(
        () => ProductoUsecase(productoRepository: injector()))
    ..registerLazySingleton<ClienteUsecase>(
        () => ClienteUsecase(clienteRepository: injector()))
    ..registerLazySingleton<ClienteVentaUsecase>(
        () => ClienteVentaUsecase(clienteRepository: injector()))
    ..registerLazySingleton<PedidoUsecase>(
        () => PedidoUsecase(pedidoRepository: injector()))
    ..registerLazySingleton<PedidoVentaUsecase>(
        () => PedidoVentaUsecase(pedidoRepository: injector()))
    ..registerLazySingleton<InventarioExpoVentaUsecase>(
        () => InventarioExpoVentaUsecase(inventarioExpoRepository: injector()))
    ..registerLazySingleton<InventarioExpoUsecase>(
        () => InventarioExpoUsecase(inventarioExpoRepository: injector()))
    ..registerLazySingleton<HistorialUsecase>(
        () => HistorialUsecase(historialRepository: injector()))
    ..registerLazySingleton<GaleriaUsecase>(
        () => GaleriaUsecase(galeriaRepository: injector()))
    ..registerLazySingleton<TicketsUsecase>(
        () => TicketsUsecase(repository: injector()))

    //* Cubits
    ..registerLazySingleton<MedidasCubit>(
        () => MedidasCubit(inventarioExpoDataSource: injector()))

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
    ..registerLazySingleton<InventarioTiendaBloc>(
        () => InventarioTiendaBloc(productoUsecase: injector()))
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
    ..registerLazySingleton<GaleriaBloc>(
        () => GaleriaBloc(galeriaUsecases: injector()))
    ..registerLazySingleton<DetalleGaleriaBloc>(
        () => DetalleGaleriaBloc(galeriaUsecases: injector()))
    ..registerLazySingleton<DetalleProductoBloc>(
        () => DetalleProductoBloc(galeriaUsecases: injector()))
    ..registerLazySingleton<ProductosTiendaBloc>(
        () => ProductosTiendaBloc(productoUsecase: injector()))
    ..registerLazySingleton<PedidoVentaBloc>(
        () => PedidoVentaBloc(pedidoUsecase: injector()))
    ..registerLazySingleton<ConsultaBloc>(
        () => ConsultaBloc(ticketsUsecase: injector()))
    ..registerLazySingleton<PedidoBloc>(
        () => PedidoBloc(pedidoUsecase: injector()));
}