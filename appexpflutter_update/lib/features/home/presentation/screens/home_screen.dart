import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 120,
          width: 120,
          child: Image.asset(
            'assets/images/logo_tufan.png',
            // color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            color: Colores.secondaryColor,
            onPressed: () {
              context.read<AuthBloc>().deleteAccessToken();
              LoginRoute().go(context);
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}
