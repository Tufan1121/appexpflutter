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
        imageUrls:
            state.uri.queryParametersAll['image-urls']!.map((e) => e).toList(),
        initialIndex: int.parse(state.uri.queryParameters['initial-index']!),
      );

  String get location => GoRouteData.$location(
        '/galeria',
        queryParams: {
          'image-urls': imageUrls.map((e) => e).toList(),
          'initial-index': initialIndex.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
