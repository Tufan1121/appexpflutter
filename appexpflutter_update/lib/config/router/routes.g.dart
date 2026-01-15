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
      factory: $LoginRoute._fromState,
    );

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => LoginRoute();

  @override
  String get location => GoRouteData.$location(
        '/login',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/home',
      factory: $HomeRoute._fromState,
    );

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => HomeRoute();

  @override
  String get location => GoRouteData.$location(
        '/home',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $preciosRoute => GoRouteData.$route(
      path: '/precios',
      factory: $PreciosRoute._fromState,
    );

mixin $PreciosRoute on GoRouteData {
  static PreciosRoute _fromState(GoRouterState state) => PreciosRoute();

  @override
  String get location => GoRouteData.$location(
        '/precios',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $photoGalleryRoute => GoRouteData.$route(
      path: '/galeria',
      factory: $PhotoGalleryRoute._fromState,
    );

mixin $PhotoGalleryRoute on GoRouteData {
  static PhotoGalleryRoute _fromState(GoRouterState state) => PhotoGalleryRoute(
        imageUrls: state.uri.queryParametersAll['image-urls']
                ?.map((e) => e)
                .toList() ??
            const [],
        initialIndex: int.parse(state.uri.queryParameters['initial-index']!),
        medidas: state.uri.queryParameters['medidas']!,
      );

  PhotoGalleryRoute get _self => this as PhotoGalleryRoute;

  @override
  String get location => GoRouteData.$location(
        '/galeria',
        queryParams: {
          'image-urls': _self.imageUrls.map((e) => e).toList(),
          'initial-index': _self.initialIndex.toString(),
          'medidas': _self.medidas,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $photoGalleryIBodegasRoute => GoRouteData.$route(
      path: '/galeria_ibodegas',
      factory: $PhotoGalleryIBodegasRoute._fromState,
    );

mixin $PhotoGalleryIBodegasRoute on GoRouteData {
  static PhotoGalleryIBodegasRoute _fromState(GoRouterState state) =>
      PhotoGalleryIBodegasRoute(
        imageUrls: state.uri.queryParametersAll['image-urls']
                ?.map((e) => e)
                .toList() ??
            const [],
        initialIndex: int.parse(state.uri.queryParameters['initial-index']!),
        userName: state.uri.queryParameters['user-name'],
        clientPhoneNumber: state.uri.queryParameters['client-phone-number'],
        $extra: state.extra as ProductoEntity,
      );

  PhotoGalleryIBodegasRoute get _self => this as PhotoGalleryIBodegasRoute;

  @override
  String get location => GoRouteData.$location(
        '/galeria_ibodegas',
        queryParams: {
          'image-urls': _self.imageUrls.map((e) => e).toList(),
          'initial-index': _self.initialIndex.toString(),
          if (_self.userName != null) 'user-name': _self.userName,
          if (_self.clientPhoneNumber != null)
            'client-phone-number': _self.clientPhoneNumber,
        },
      );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $photoGalleryRoute2 => GoRouteData.$route(
      path: '/galeria_dos',
      factory: $PhotoGalleryRoute2._fromState,
    );

mixin $PhotoGalleryRoute2 on GoRouteData {
  static PhotoGalleryRoute2 _fromState(GoRouterState state) =>
      PhotoGalleryRoute2(
        imageUrls: state.uri.queryParametersAll['image-urls']
                ?.map((e) => e)
                .toList() ??
            const [],
        initialIndex: int.parse(state.uri.queryParameters['initial-index']!),
        $extra: state.extra as ProductoExpoEntity,
      );

  PhotoGalleryRoute2 get _self => this as PhotoGalleryRoute2;

  @override
  String get location => GoRouteData.$location(
        '/galeria_dos',
        queryParams: {
          'image-urls': _self.imageUrls.map((e) => e).toList(),
          'initial-index': _self.initialIndex.toString(),
        },
      );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $clienteNuevoRoute => GoRouteData.$route(
      path: '/cliente_nuevo',
      factory: $ClienteNuevoRoute._fromState,
    );

mixin $ClienteNuevoRoute on GoRouteData {
  static ClienteNuevoRoute _fromState(GoRouterState state) =>
      ClienteNuevoRoute();

  @override
  String get location => GoRouteData.$location(
        '/cliente_nuevo',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $clienteNuevoVentaRoute => GoRouteData.$route(
      path: '/cliente_nuevo_venta',
      factory: $ClienteNuevoVentaRoute._fromState,
    );

mixin $ClienteNuevoVentaRoute on GoRouteData {
  static ClienteNuevoVentaRoute _fromState(GoRouterState state) =>
      ClienteNuevoVentaRoute();

  @override
  String get location => GoRouteData.$location(
        '/cliente_nuevo_venta',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $clienteExistenteRoute => GoRouteData.$route(
      path: '/cliente_existente',
      factory: $ClienteExistenteRoute._fromState,
    );

mixin $ClienteExistenteRoute on GoRouteData {
  static ClienteExistenteRoute _fromState(GoRouterState state) =>
      ClienteExistenteRoute();

  @override
  String get location => GoRouteData.$location(
        '/cliente_existente',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pedidoRoute => GoRouteData.$route(
      path: '/pedido',
      factory: $PedidoRoute._fromState,
    );

mixin $PedidoRoute on GoRouteData {
  static PedidoRoute _fromState(GoRouterState state) => PedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        nombreCliente: state.uri.queryParameters['nombre-cliente']!,
        telefonoCliente: state.uri.queryParameters['telefono-cliente']!,
      );

  PedidoRoute get _self => this as PedidoRoute;

  @override
  String get location => GoRouteData.$location(
        '/pedido',
        queryParams: {
          'id-cliente': _self.idCliente.toString(),
          'nombre-cliente': _self.nombreCliente,
          'telefono-cliente': _self.telefonoCliente,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $generarPedidoRoute => GoRouteData.$route(
      path: '/generar_pedido',
      factory: $GenerarPedidoRoute._fromState,
    );

mixin $GenerarPedidoRoute on GoRouteData {
  static GenerarPedidoRoute _fromState(GoRouterState state) =>
      GenerarPedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
        idSesion: _$convertMapValue(
            'id-sesion', state.uri.queryParameters, int.tryParse),
        telefonoCliente: state.uri.queryParameters['telefono-cliente']!,
      );

  GenerarPedidoRoute get _self => this as GenerarPedidoRoute;

  @override
  String get location => GoRouteData.$location(
        '/generar_pedido',
        queryParams: {
          'id-cliente': _self.idCliente.toString(),
          'estado-pedido': _self.estadoPedido.toString(),
          if (_self.idSesion != null) 'id-sesion': _self.idSesion!.toString(),
          'telefono-cliente': _self.telefonoCliente,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

RouteBase get $generarPedidoVentaRoute => GoRouteData.$route(
      path: '/generar_pedido_venta',
      factory: $GenerarPedidoVentaRoute._fromState,
    );

mixin $GenerarPedidoVentaRoute on GoRouteData {
  static GenerarPedidoVentaRoute _fromState(GoRouterState state) =>
      GenerarPedidoVentaRoute(
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
        idSesion: _$convertMapValue(
            'id-sesion', state.uri.queryParameters, int.tryParse),
        $extra: state.extra as Map<String, dynamic>,
      );

  GenerarPedidoVentaRoute get _self => this as GenerarPedidoVentaRoute;

  @override
  String get location => GoRouteData.$location(
        '/generar_pedido_venta',
        queryParams: {
          'estado-pedido': _self.estadoPedido.toString(),
          if (_self.idSesion != null) 'id-sesion': _self.idSesion!.toString(),
        },
      );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $sesionPedidoRoute => GoRouteData.$route(
      path: '/sesion_pedido',
      factory: $SesionPedidoRoute._fromState,
    );

mixin $SesionPedidoRoute on GoRouteData {
  static SesionPedidoRoute _fromState(GoRouterState state) => SesionPedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
      );

  SesionPedidoRoute get _self => this as SesionPedidoRoute;

  @override
  String get location => GoRouteData.$location(
        '/sesion_pedido',
        queryParams: {
          'id-cliente': _self.idCliente.toString(),
          'estado-pedido': _self.estadoPedido.toString(),
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $cotizaPedidoRoute => GoRouteData.$route(
      path: '/cotiza_pedido',
      factory: $CotizaPedidoRoute._fromState,
    );

mixin $CotizaPedidoRoute on GoRouteData {
  static CotizaPedidoRoute _fromState(GoRouterState state) => CotizaPedidoRoute(
        idCliente: int.parse(state.uri.queryParameters['id-cliente']!),
        estadoPedido: int.parse(state.uri.queryParameters['estado-pedido']!),
      );

  CotizaPedidoRoute get _self => this as CotizaPedidoRoute;

  @override
  String get location => GoRouteData.$location(
        '/cotiza_pedido',
        queryParams: {
          'id-cliente': _self.idCliente.toString(),
          'estado-pedido': _self.estadoPedido.toString(),
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $invetarioExpoRoute => GoRouteData.$route(
      path: '/inventario_expo',
      factory: $InvetarioExpoRoute._fromState,
    );

mixin $InvetarioExpoRoute on GoRouteData {
  static InvetarioExpoRoute _fromState(GoRouterState state) =>
      InvetarioExpoRoute();

  @override
  String get location => GoRouteData.$location(
        '/inventario_expo',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $invetarioBodegaRoute => GoRouteData.$route(
      path: '/inventario_bodega',
      factory: $InvetarioBodegaRoute._fromState,
    );

mixin $InvetarioBodegaRoute on GoRouteData {
  static InvetarioBodegaRoute _fromState(GoRouterState state) =>
      InvetarioBodegaRoute();

  @override
  String get location => GoRouteData.$location(
        '/inventario_bodega',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $busquedaGlobalRoute => GoRouteData.$route(
      path: '/busqueda_global',
      factory: $BusquedaGlobalRoute._fromState,
    );

mixin $BusquedaGlobalRoute on GoRouteData {
  static BusquedaGlobalRoute _fromState(GoRouterState state) =>
      BusquedaGlobalRoute();

  @override
  String get location => GoRouteData.$location(
        '/busqueda_global',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $historialRoute => GoRouteData.$route(
      path: '/historial',
      factory: $HistorialRoute._fromState,
    );

mixin $HistorialRoute on GoRouteData {
  static HistorialRoute _fromState(GoRouterState state) => HistorialRoute();

  @override
  String get location => GoRouteData.$location(
        '/historial',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $galeriaRoute => GoRouteData.$route(
      path: '/galeria_global',
      factory: $GaleriaRoute._fromState,
    );

mixin $GaleriaRoute on GoRouteData {
  static GaleriaRoute _fromState(GoRouterState state) => GaleriaRoute();

  @override
  String get location => GoRouteData.$location(
        '/galeria_global',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $puntoVentaRoute => GoRouteData.$route(
      path: '/punto_venta_global',
      factory: $PuntoVentaRoute._fromState,
    );

mixin $PuntoVentaRoute on GoRouteData {
  static PuntoVentaRoute _fromState(GoRouterState state) => PuntoVentaRoute();

  @override
  String get location => GoRouteData.$location(
        '/punto_venta_global',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $ticketsRoute => GoRouteData.$route(
      path: '/tickets',
      factory: $TicketsRoute._fromState,
    );

mixin $TicketsRoute on GoRouteData {
  static TicketsRoute _fromState(GoRouterState state) => TicketsRoute(
        $extra: state.extra as Map<String, dynamic>,
      );

  TicketsRoute get _self => this as TicketsRoute;

  @override
  String get location => GoRouteData.$location(
        '/tickets',
      );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $puntoVentaHistoryRoute => GoRouteData.$route(
      path: '/historial_punto_venta',
      factory: $PuntoVentaHistoryRoute._fromState,
    );

mixin $PuntoVentaHistoryRoute on GoRouteData {
  static PuntoVentaHistoryRoute _fromState(GoRouterState state) =>
      PuntoVentaHistoryRoute();

  @override
  String get location => GoRouteData.$location(
        '/historial_punto_venta',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
