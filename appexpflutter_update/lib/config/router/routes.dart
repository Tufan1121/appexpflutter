import 'package:appexpflutter_update/features/galeria/presentation/screens/galeria_screen.dart';
import 'package:inventarios/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/inventario_bodega_screen.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/inventario_tienda_screen.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/inventario_global_screen.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/screen_gallery2.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/screen_gallery_ibodega.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/screens/cliente_nuevo_screen.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/screens/generar_pedido_venta_screen.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/screens/consulta_punto_screen.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/screens/punto_venta_screen.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/screens/tickets_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/cliente_existente_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/cliente_nuevo_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/cotiza_pedido_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/pedido_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/generar_pedido_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/sesion_pedido_screen.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/home_screen.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/precios_screen.dart';
import 'package:precios/domain/entities/producto_entity.dart';
import '../../features/auth/presentation/screens/auth/login_screen.dart';
import '../../features/precios/presentation/screens/widgets/screen_gallery.dart';

part 'routes.g.dart';

@TypedGoRoute<LoginRoute>(
  path: LoginRoute.path,
)
class LoginRoute extends GoRouteData {
  static const path = '/login';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<HomeRoute>(
  path: HomeRoute.path,
)
class HomeRoute extends GoRouteData {
  HomeRoute();
  static const path = '/home';
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<PreciosRoute>(
  path: PreciosRoute.path,
)
class PreciosRoute extends GoRouteData {
  static const path = '/precios';
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PreciosScreen();
}

@TypedGoRoute<PhotoGalleryRoute>(
  path: PhotoGalleryRoute.path,
)
class PhotoGalleryRoute extends GoRouteData {
  static const path = '/galeria';
  final List<String> imageUrls;
  final int initialIndex;
  final String medidas;
  PhotoGalleryRoute(
      {required this.imageUrls,
      required this.initialIndex,
      required this.medidas});

  @override
  Widget build(BuildContext context, GoRouterState state) => FullScreenGallery(
      imageUrls: imageUrls, initialIndex: initialIndex, medidas: medidas);
}

@TypedGoRoute<PhotoGalleryIBodegasRoute>(
  path: PhotoGalleryIBodegasRoute.path,
)
class PhotoGalleryIBodegasRoute extends GoRouteData {
  static const path = '/galeria_ibodegas';
  final List<String> imageUrls;
  final int initialIndex;
  final ProductoEntity $extra;
  final String? userName;
  final String? clientPhoneNumber;

  PhotoGalleryIBodegasRoute(
      {required this.imageUrls,
      required this.initialIndex,
      required this.$extra,
      this.userName,
      this.clientPhoneNumber});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FullScreenGalleryIBodegas(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
        producto: $extra,
        userName: userName,
        clientPhoneNumber: clientPhoneNumber,
      );
}

@TypedGoRoute<PhotoGalleryRoute2>(
  path: PhotoGalleryRoute2.path,
)
class PhotoGalleryRoute2 extends GoRouteData {
  static const path = '/galeria_dos';
  final List<String> imageUrls;
  final int initialIndex;
  final ProductoExpoEntity $extra;

  PhotoGalleryRoute2(
      {required this.imageUrls,
      required this.initialIndex,
      required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) => FullScreenGallery2(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
        producto: $extra,
      );
}

@TypedGoRoute<ClienteNuevoRoute>(
  path: ClienteNuevoRoute.path,
)
class ClienteNuevoRoute extends GoRouteData {
  static const path = '/cliente_nuevo';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ClienteNuevoScreen();
}

@TypedGoRoute<ClienteNuevoVentaRoute>(
  path: ClienteNuevoVentaRoute.path,
)
class ClienteNuevoVentaRoute extends GoRouteData {
  static const path = '/cliente_nuevo_venta';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ClienteNuevoVentaScreen();
}

@TypedGoRoute<ClienteExistenteRoute>(
  path: ClienteExistenteRoute.path,
)
class ClienteExistenteRoute extends GoRouteData {
  static const path = '/cliente_existente';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ClienteExistenteScreen();
}

@TypedGoRoute<PedidoRoute>(
  path: PedidoRoute.path,
)
class PedidoRoute extends GoRouteData {
  static const path = '/pedido';
  final int idCliente;
  final String nombreCliente;
  final String telefonoCliente;

  PedidoRoute(
      {required this.idCliente,
      required this.nombreCliente,
      required this.telefonoCliente});

  @override
  Widget build(BuildContext context, GoRouterState state) => PedidoScreen(
        idCliente: idCliente,
        nombreCliente: nombreCliente,
        telefonoCliente: telefonoCliente,
      );
}

@TypedGoRoute<GenerarPedidoRoute>(
  path: GenerarPedidoRoute.path,
)
class GenerarPedidoRoute extends GoRouteData {
  static const path = '/generar_pedido';
  final int idCliente;
  final int estadoPedido;
  final int? idSesion;
  final String telefonoCliente;

  GenerarPedidoRoute(
      {required this.idCliente,
      required this.estadoPedido,
      this.idSesion,
      required this.telefonoCliente});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      GenerarPedidoScreen(
        idCliente: idCliente,
        estadoPedido: estadoPedido,
        idSesion: idSesion,
        telefonoCliente: telefonoCliente,
      );
}

@TypedGoRoute<GenerarPedidoVentaRoute>(
  path: GenerarPedidoVentaRoute.path,
)
class GenerarPedidoVentaRoute extends GoRouteData {
  static const path = '/generar_pedido_venta';
  // final int idCliente;
  final int estadoPedido;
  final int? idSesion;
  final Map<String, dynamic> $extra;

  GenerarPedidoVentaRoute({
    // required this.idCliente,
    required this.estadoPedido,
    this.idSesion,
    required this.$extra,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      GenerarPedidoVentaScreen(
        // idCliente: idCliente,
        estadoPedido: estadoPedido,
        idSesion: idSesion,
        dataCliente: $extra,
      );
}

@TypedGoRoute<SesionPedidoRoute>(
  path: SesionPedidoRoute.path,
)
class SesionPedidoRoute extends GoRouteData {
  static const path = '/sesion_pedido';
  final int idCliente;
  final int estadoPedido;

  SesionPedidoRoute({
    required this.idCliente,
    required this.estadoPedido,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) => SesionPedidoScreen(
        idCliente: idCliente,
        estadoPedido: estadoPedido,
      );
}

@TypedGoRoute<CotizaPedidoRoute>(
  path: CotizaPedidoRoute.path,
)
class CotizaPedidoRoute extends GoRouteData {
  static const path = '/cotiza_pedido';
  final int idCliente;
  final int estadoPedido;

  CotizaPedidoRoute({
    required this.idCliente,
    required this.estadoPedido,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) => CotizaPedidoScreen(
        idCliente: idCliente,
        estadoPedido: estadoPedido,
      );
}

@TypedGoRoute<InvetarioExpoRoute>(
  path: InvetarioExpoRoute.path,
)
class InvetarioExpoRoute extends GoRouteData {
  static const path = '/inventario_expo';

  InvetarioExpoRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InventarioTiendaScreen();
}

@TypedGoRoute<InvetarioBodegaRoute>(
  path: InvetarioBodegaRoute.path,
)
class InvetarioBodegaRoute extends GoRouteData {
  static const path = '/inventario_bodega';

  InvetarioBodegaRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InventarioBodegaScreen();
}

@TypedGoRoute<BusquedaGlobalRoute>(
  path: BusquedaGlobalRoute.path,
)
class BusquedaGlobalRoute extends GoRouteData {
  static const path = '/busqueda_global';

  BusquedaGlobalRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BusquedaGlobalScreen();
}

@TypedGoRoute<GaleriaRoute>(
  path: GaleriaRoute.path,
)
class GaleriaRoute extends GoRouteData {
  static const path = '/galeria_global';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const GaleriaScreen();
}

@TypedGoRoute<PuntoVentaRoute>(
  path: PuntoVentaRoute.path,
)
class PuntoVentaRoute extends GoRouteData {
  static const path = '/punto_venta_global';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PuntoVentaScreen();
}

@TypedGoRoute<TicketsRoute>(
  path: TicketsRoute.path,
)
class TicketsRoute extends GoRouteData {
  static const path = '/tickets';
  final Map<String, dynamic> $extra;

  TicketsRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TicketsScreen(data: $extra);
}

@TypedGoRoute<PuntoVentaHistoryRoute>(
  path: PuntoVentaHistoryRoute.path,
)
class PuntoVentaHistoryRoute extends GoRouteData {
  static const path = '/historial_punto_venta';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PuntoVentaConsultaScreen();
}
