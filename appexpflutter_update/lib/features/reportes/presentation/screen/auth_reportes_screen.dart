import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/features/reportes/presentation/bloc/reportes_bloc.dart';
import 'package:appexpflutter_update/features/reportes/presentation/screen/widgets/movil_form.dart';
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthReportesScreen extends StatelessWidget {
  const AuthReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: GeometricalBackground(
              child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
              iconSize: 30,
            ),
            const SizedBox(height: 30),
            // Icon Banner
            Center(
              child: Image.asset(
                'assets/images/logo_tufan.png',
                scale: 10,
              ),
            ),
            const SizedBox(height: 80),

            Container(
              height: size.height - 260, // 80 los dos sizebox y 100 el ícono
              width: double.infinity,
              decoration: BoxDecoration(
                color: scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(100)),
              ),
              child: const MovilForm(),
            )
          ],
        ),
      ))),
    );
  }
}
