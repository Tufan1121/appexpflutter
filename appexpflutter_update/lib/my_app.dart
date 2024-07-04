import 'package:appexpflutter_update/features/inventarios/presentation/blocs/busqueda_global/busqueda_global_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_bodega/inventario_bodega_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_expo/inventario_expo_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/inventario/inventario_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/pedido/pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/session_pedido/sesion_pedido_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/main.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  final storage = const FlutterSecureStorage();

  Future<void> _init() async {
    final token = await storage.read(key: 'accessToken');
    // _router =
    //     GoRouter(initialLocation: GenerarPedidoRoute.path, routes: $appRoutes);
    _router = GoRouter(
        initialLocation: token != null ? HomeRoute.path : LoginRoute.path,
        routes: $appRoutes);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => injector<AuthBloc>()),
        BlocProvider<PreciosBloc>(create: (_) => injector<PreciosBloc>()),
        BlocProvider<ProductosBloc>(create: (_) => injector<ProductosBloc>()),
        BlocProvider<ClienteBloc>(create: (_) => injector<ClienteBloc>()),
        BlocProvider<PedidoBloc>(create: (_) => injector<PedidoBloc>()),
        BlocProvider<SesionPedidoBloc>(
            create: (_) => injector<SesionPedidoBloc>()),
        BlocProvider<InventarioBloc>(create: (_) => injector<InventarioBloc>()),
        BlocProvider<InventarioBodegaBloc>(
            create: (_) => injector<InventarioBodegaBloc>()),
        BlocProvider<InventarioExpoBloc>(
            create: (_) => injector<InventarioExpoBloc>()),
        BlocProvider<BusquedaGlobalBloc>(
            create: (_) => injector<BusquedaGlobalBloc>()),
      ],
      child: FutureBuilder(
        future: _init(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return Container();
          }
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Tufan',
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
