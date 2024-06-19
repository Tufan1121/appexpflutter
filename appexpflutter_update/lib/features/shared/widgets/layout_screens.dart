import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LayoutScreens extends StatelessWidget {
  const LayoutScreens({
    super.key,
    this.icon,
    this.faIcon,
    this.titleScreen,
    this.child,
    required this.onPressed,
  });
  final IconData? icon;
  final IconData? faIcon;
  final String? titleScreen;
  final Widget? child;
  final void Function()? onPressed;

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: onPressed,
                    icon: const Icon(Icons.arrow_back_rounded,
                        size: 30, color: Colores.scaffoldBackgroundColor)),
                const SizedBox(width: 50),
                Text(
                  titleScreen ?? 'title',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colores.scaffoldBackgroundColor,
                      shadows: [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2.0, 5.0),
                        )
                      ]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 75),
              child ?? Container(),
            ],
          ),
        ],
      ),
    );
  }
}
