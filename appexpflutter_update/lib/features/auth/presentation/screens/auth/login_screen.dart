import 'package:flutter/material.dart';
import 'package:appexpflutter_update/features/auth/presentation/screens/auth/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Mantiene la imagen de fondo fija
        body: Stack(
          children: [
            // Imagen de fondo
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/fondo.png',
                  ),
                  fit: BoxFit
                      .cover, // Asegura que la imagen de fondo se vea completa
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size
                        .height, // Asegura que el ScrollView ocupe toda la pantalla
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 90),
                        // Icono banner
                        Image.asset(
                          'assets/images/tufan_logo.png',
                          scale: 2.5,
                        ),
                        const SizedBox(height: 80),
                        // Contenedor con el formulario
                        Container(
                          height:
                              size.height - 400, // Mantiene el tamaño de 380
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(100)),
                          ),
                          child: const LoginForm(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
