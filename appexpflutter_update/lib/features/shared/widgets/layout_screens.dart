import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LayoutScreens extends StatelessWidget {
  const LayoutScreens({
    super.key,
    this.icon,
    this.titleScreen,
    this.child,
  });
  final IconData? icon;
  final String? titleScreen;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: BackgroundPainter(),
          ),
          SafeArea(
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_rounded,
                    size: 30, color: Colores.scaffoldBackgroundColor)),
          ),
          Column(
            children: [
              const SizedBox(height: 55),
              Center(
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: Colores.scaffoldBackgroundColor,
                      size: 100,
                      shadows: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2.0, 5.0),
                        )
                      ],
                    ),
                    Text(
                      titleScreen ?? 'title',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colores.scaffoldBackgroundColor,
                          shadows: [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2.0, 5.0),
                            )
                          ]),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              child ?? Container(),
            ],
          ),
        ],
      ),
    );
  }
}
