// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $loginRoute,
      $homeRoute,
      $preciosRoute,
      $photoGalleryRoute,
      $photoGalleryIBodegasRoute,
      $photoGalleryRoute2,
      $clienteNuevoRoute,
      $clienteNuevoVentaRoute,
      $clienteExistenteRoute,
      $pedidoRoute,
      $generarPedidoRoute,
      $generarPedidoVentaRoute,
      $sesionPedidoRoute,
      $cotizaPedidoRoute,
      $invetarioExpoRoute,
      $invetarioBodegaRoute,
      $busquedaGlobalRoute,
      $historialRoute,
      $galeriaRoute,
      $puntoVentaRoute,
      $ticketsRoute,
      $puntoVentaHistoryRoute,
    ];

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: $LoginRouteExtension._fromState,
    );

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => LoginRoute();

  String get location => GoRouteData.$location(
        '/login',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/home',
      factory: $HomeRouteExtension._fromState,
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => HomeRoute();

  String get location => GoRouteData.$location(
        '/home',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $preciosRoute => GoRouteData.$route(
      path: '/precios',
      factory: $PreciosRouteExtension._fromState,
    );

extension $PreciosRouteExtension on PreciosRoute {
  static PreciosRoute _fromState(GoRouterState state) => PreciosRoute();

  String get location => GoRouteData.$location(
        '/precios',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $photoGalleryRoute => GoRouteData.$route(
      path: '/galeria',
      factory: $PhotoGalleryRouteExtension._fromState,
    );

extension $PhotoGalleryRouteExtension on PhotoGalleryRoute {
  static PhotoGalleryRoute _fromState(GoRouterState state) => PhotoGalleryRoute(
        imageUrls: state.uri.queryParametersAll['image-urls']
                ?.map((e) => e)
                .toList() ??
            [],
        initialIndex: int.parse(state.uri.queryParameters['initial-index']!),
        medidas: state.uri.queryParameters['medidas']!,
      );

  String get location => GoRouteData.$location(
        '/galeria',
        queryParams: {
          'image-urls': imageUrls.map((e) => e).toList(),
          'initial-index': initialIndex.toString(),
          'medidas': medidas,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $photoGalleryIBodegasRoute => GoRouteData.$route(
      path: '/galeria_ibodegas',
      factory: $PhotoGalleryIBodegasRouteExtension._fromState,
    );

extension $PhotoGalleryIBodegasRouteExtension on PhotoGalleryIBodegasRoute {
  static PhotoGalleryIBodegasRoute _fromState(GoRouterState state) =>
      PhotoGalleryIBodegasRoute(
        imageUrls: state.uri.queryParametersAll['image-urls']
                ?.map((e) => e)
                .toList() ??
            [],
        initialIndex: int.parse(state.uri.queryParameters['initial-index']!),
        userName: state.uri.queryParameters['user-name'],
        clientPhoneNumber: state.uri.queryParameters['client-phone-number'],
        $extra: state.extra as ProductoEntity,
      );

  String get location => GoRouteData.$location(
        '/galeria_ibodegas',
        queryParams: {
          'image-urls': imageUrls.map((e) => e).toList(),
          'initial-index': initialIndex.toString(),
          if (userName != null) 'user-name': userName,
          if (clientPhoneNumber != null)
            'client-phone-number': clientPhoneNumber,
        },
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $photoGalleryRoute2 => GoRouteData.$route(
      path: '/galeria_dos',
      factory: $PhotoGalleryRoute2Extension._fromState,
    );

extension $PhotoGalleryRoute2Extension on PhotoGalleryRoute2 {
  static PhotoGalleryRoute2 _fromState(GoRouterState state) =>
      PhotoGalleryRoute2(
        imageUrls: state.uri.queryParametersAll['image-urls']
                ?.map((e) => e)
                .toList() ??
            [],
        initialIndex: int.parse(state.uri.queryParameters['initial-index']!),
        $extra: state.extra as ProductoExpoEntity,
      );

  String get location => GoRouteData.$location(
        '/galeria_dos',
        queryParams: {
          'image-urls': imageUrls.map((e) => e).toList(),
          'initial-index': initialIndex.toString(),
        },
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $clienteNuevoRoute => GoRouteData.$route(
      path: '/cliente_nuevo',
      factory: $ClienteNuevoRouteExtension._fromState,
    );

extension $ClienteNuevoRouteExtension on ClienteNuevoRoute {
  static ClienteNuevoRoute _fromState(GoRouterState state) =>
      ClienteNuevoRoute();

  String get location => GoRouteData.$location(
        '/cliente_nuevo',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $clienteNuevoVentaRoute => GoRouteData.$route(
      path: '/cliente_nuevo_venta',
      factory: $ClienteNuevoVentaRouteExtension._fromState,
    );

extension $ClienteNuevoVentaRouteExtension on ClienteNuevoVentaRoute {
  static ClienteNuevoVentaRoute _fromState(GoRouterState state) =>
      ClienteNuevoVentaRoute();

  String get location => GoRouteData.$location(
        '/cliente_nuevo_venta',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $clienteExistenteRoute => GoRouteData.$route(
      path: '/cliente_existente',
      factory: $ClienteExistenteRouteExtension._fromState,
    );

extension $ClienteExistenteRouteExtension on ClienteExistenteRoute {
  static ClienteExistenteRoute _fromState(GoRouterState state) =>
      ClienteExistenteRoute();

  String get location => GoRouteData.$location(
        '/cliente_existente',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pedidoRoute => GoRouteData.$route(
      path: '/pedido',
      factory: $PedidoRouteExtension._fromState,
    );

extension $PedidoRouteExtension on PedidoRoute {
  static PedidoRoute _fromState(GoRouterState state) => PedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        nombreCliente: state.uri.queryParameters['nombre-cliente']!,
        telefonoCliente: state.uri.queryParameters['telefono-cliente']!,
      );

  String get location => GoRouteData.$location(
        '/pedido',
        queryParams: {
          'id-cliente': idCliente.toString(),
          'nombre-cliente': nombreCliente,
          'telefono-cliente': telefonoCliente,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $generarPedidoRoute => GoRouteData.$route(
      path: '/generar_pedido',
      factory: $GenerarPedidoRouteExtension._fromState,
    );

extension $GenerarPedidoRouteExtension on GenerarPedidoRoute {
  static GenerarPedidoRoute _fromState(GoRouterState state) =>
      GenerarPedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
        idSesion: _$convertMapValue(
            'id-sesion', state.uri.queryParameters, int.parse),
        telefonoCliente: state.uri.queryParameters['telefono-cliente']!,
      );

  String get location => GoRouteData.$location(
        '/generar_pedido',
        queryParams: {
          'id-cliente': idCliente.toString(),
          'estado-pedido': estadoPedido.toString(),
          if (idSesion != null) 'id-sesion': idSesion!.toString(),
          'telefono-cliente': telefonoCliente,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

RouteBase get $generarPedidoVentaRoute => GoRouteData.$route(
      path: '/generar_pedido_venta',
      factory: $GenerarPedidoVentaRouteExtension._fromState,
    );

extension $GenerarPedidoVentaRouteExtension on GenerarPedidoVentaRoute {
  static GenerarPedidoVentaRoute _fromState(GoRouterState state) =>
      GenerarPedidoVentaRoute(
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
        idSesion: _$convertMapValue(
            'id-sesion', state.uri.queryParameters, int.parse),
        $extra: state.extra as Map<String, dynamic>,
      );

  String get location => GoRouteData.$location(
        '/generar_pedido_venta',
        queryParams: {
          'estado-pedido': estadoPedido.toString(),
          if (idSesion != null) 'id-sesion': idSesion!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $sesionPedidoRoute => GoRouteData.$route(
      path: '/sesion_pedido',
      factory: $SesionPedidoRouteExtension._fromState,
    );

extension $SesionPedidoRouteExtension on SesionPedidoRoute {
  static SesionPedidoRoute _fromState(GoRouterState state) => SesionPedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
      );

  String get location => GoRouteData.$location(
        '/sesion_pedido',
        queryParams: {
          'id-cliente': idCliente.toString(),
          'estado-pedido': estadoPedido.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $cotizaPedidoRoute => GoRouteData.$route(
      path: '/cotiza_pedido',
      factory: $CotizaPedidoRouteExtension._fromState,
    );

extension $CotizaPedidoRouteExtension on CotizaPedidoRoute {
  static CotizaPedidoRoute _fromState(GoRouterState state) => CotizaPedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
      );

  String get location => GoRouteData.$location(
        '/cotiza_pedido',
        queryParams: {
          'id-cliente': idCliente.toString(),
          'estado-pedido': estadoPedido.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $invetarioExpoRoute => GoRouteData.$route(
      path: '/inventario_expo',
      factory: $InvetarioExpoRouteExtension._fromState,
    );

extension $InvetarioExpoRouteExtension on InvetarioExpoRoute {
  static InvetarioExpoRoute _fromState(GoRouterState state) =>
      InvetarioExpoRoute();

  String get location => GoRouteData.$location(
        '/inventario_expo',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $invetarioBodegaRoute => GoRouteData.$route(
      path: '/inventario_bodega',
      factory: $InvetarioBodegaRouteExtension._fromState,
    );

extension $InvetarioBodegaRouteExtension on InvetarioBodegaRoute {
  static InvetarioBodegaRoute _fromState(GoRouterState state) =>
      InvetarioBodegaRoute();

  String get location => GoRouteData.$location(
        '/inventario_bodega',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $busquedaGlobalRoute => GoRouteData.$route(
      path: '/busqueda_global',
      factory: $BusquedaGlobalRouteExtension._fromState,
    );

extension $BusquedaGlobalRouteExtension on BusquedaGlobalRoute {
  static BusquedaGlobalRoute _fromState(GoRouterState state) =>
      BusquedaGlobalRoute();

  String get location => GoRouteData.$location(
        '/busqueda_global',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $historialRoute => GoRouteData.$route(
      path: '/historial',
      factory: $HistorialRouteExtension._fromState,
    );

extension $HistorialRouteExtension on HistorialRoute {
  static HistorialRoute _fromState(GoRouterState state) => HistorialRoute();

  String get location => GoRouteData.$location(
        '/historial',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $galeriaRoute => GoRouteData.$route(
      path: '/galeria_global',
      factory: $GaleriaRouteExtension._fromState,
    );

extension $GaleriaRouteExtension on GaleriaRoute {
  static GaleriaRoute _fromState(GoRouterState state) => GaleriaRoute();

  String get location => GoRouteData.$location(
        '/galeria_global',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $puntoVentaRoute => GoRouteData.$route(
      path: '/punto_venta_global',
      factory: $PuntoVentaRouteExtension._fromState,
    );

extension $PuntoVentaRouteExtension on PuntoVentaRoute {
  static PuntoVentaRoute _fromState(GoRouterState state) => PuntoVentaRoute();

  String get location => GoRouteData.$location(
        '/punto_venta_global',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $ticketsRoute => GoRouteData.$route(
      path: '/tickets',
      factory: $TicketsRouteExtension._fromState,
    );

extension $TicketsRouteExtension on TicketsRoute {
  static TicketsRoute _fromState(GoRouterState state) => TicketsRoute(
        $extra: state.extra as Map<String, dynamic>,
      );

  String get location => GoRouteData.$location(
        '/tickets',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $puntoVentaHistoryRoute => GoRouteData.$route(
      path: '/historial_punto_venta',
      factory: $PuntoVentaHistoryRouteExtension._fromState,
    );

extension $PuntoVentaHistoryRouteExtension on PuntoVentaHistoryRoute {
  static PuntoVentaHistoryRoute _fromState(GoRouterState state) =>
      PuntoVentaHistoryRoute();

  String get location => GoRouteData.$location(
        '/historial_punto_venta',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
