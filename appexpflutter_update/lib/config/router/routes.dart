import 'package:appexpflutter_update/features/ventas/presentation/screens/cliente_existente_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/cliente_nuevo_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/pedido_screen.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/generar_pedido.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/home_screen.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/precios_screen.dart';
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
  PhotoGalleryRoute({required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FullScreenGallery(imageUrls: imageUrls, initialIndex: initialIndex);
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

  PedidoRoute({required this.idCliente, required this.nombreCliente});

  @override
  Widget build(BuildContext context, GoRouterState state) => PedidoScreen(
        idCliente: idCliente,
        nombreCliente: nombreCliente,
      );
}

@TypedGoRoute<GenerarPedidoRoute>(
  path: GenerarPedidoRoute.path,
)
class GenerarPedidoRoute extends GoRouteData {
  static const path = '/generar_pedido';
  final int idCliente;
  final int estadoPedido;

  GenerarPedidoRoute({
    required this.idCliente,
    required this.estadoPedido,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      GenerarPedidoScreen(
        idCliente: idCliente,
        estadoPedido: estadoPedido,
      );
}


// @TypedGoRoute<GenerarPedidoRoute>(
//   path: GenerarPedidoRoute.path,
// )
// class GenerarPedidoRoute extends GoRouteData {
//   static const path = '/generar_pedido';

//   GenerarPedidoRoute(
//   );

//   @override

//   Widget build(BuildContext context, GoRouterState state) =>
//       const GenerarPedidoScreen2(
//       );
// }


