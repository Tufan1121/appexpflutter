import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/main.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
// late GoRouter _router;

  // Future<void> _init() async {
  //   final bloc = context.read<AuthBloc>();
  //   final token = await bloc.getAccessToken();
  //   _router = GoRouter(initialLocation: token != null ? HomeRoute.path : LoginRoute.path, routes: $appRoutes);
  // }
  final _router =
      GoRouter(initialLocation: LoginRoute.path, routes: $appRoutes);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => injector<AuthBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Tufan',
        routerConfig: _router,
      ),
    );
  }
}
