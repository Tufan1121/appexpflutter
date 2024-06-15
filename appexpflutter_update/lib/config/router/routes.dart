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
  Widget build(BuildContext context, GoRouterState state) => const PreciosScreen();
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
      FullScreenGallery(imageUrls:imageUrls, initialIndex: initialIndex);
}
