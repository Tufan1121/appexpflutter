import 'package:appexpflutter_update/features/ventas/presentation/bloc/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/producto/productos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:appexpflutter_update/main.dart';
import 'package:appexpflutter_update/config/config.dart';
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
