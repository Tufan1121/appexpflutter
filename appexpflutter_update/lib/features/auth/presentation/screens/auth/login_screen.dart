import 'package:flutter/material.dart';
import 'package:appexpflutter_update/features/auth/presentation/screens/auth/widgets/login_form.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    // En tablet/landscape limitamos el ancho del panel blanco a 560 px y lo
    // centramos. En phone (ancho < 600 px) ocupa todo como antes.
    final isWide = size.width >= 600;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: GeometricalBackground(
              child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            // Icon Banner
            Image.asset(
              'assets/images/logo_tufan.png',
              scale: 10,
            ),
            const SizedBox(height: 80),

            Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: isWide ? 560 : double.infinity),
                child: Container(
                  height: size.height - 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(100)),
                  ),
                  child: const LoginForm(),
                ),
              ),
            )
          ],
        ),
      ))),
    );
  }
}
