import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/main.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source_impl.dart';
// import 'package:appexpflutter_update/features/auth/data/repositories/auth_repository_impl.dart';
// import 'package:appexpflutter_update/features/auth/domain/usecases/auth_usecase.dart';
// import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    _router = GoRouter(initialLocation: '/login', routes: $appRoutes);
    return MultiBlocProvider(
      providers: [
        // BlocProvider(
        //     create: (_) => AuthBloc(
        //         authUsecase: AuthUsecase(
        //             authRepository: AuthRepositoryImpl(
        //                 authDatasource:
        //                     AuthDataSourceImpl(dioClient: DioClient()))))),
        BlocProvider(create: (_) => injector<AuthBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Tufan',
        routerConfig: _router,
      ),
    );
  }
}
