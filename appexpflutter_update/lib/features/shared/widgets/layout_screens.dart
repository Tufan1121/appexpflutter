import 'dart:math' show Random;
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/theme/responsive.dart';
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
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = false,
    this.actions,
  });
  final IconData? icon;
  final IconData? faIcon;
  final String? titleScreen;
  final Widget? child;
  final void Function()? onPressed;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Container(
        width: double.infinity,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colores.scaffoldBackgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Premium gradient header with carpet pattern
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colores.gradientStart,
                      Colores.gradientMiddle,
                      Colores.gradientEnd,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Carpet-inspired geometric pattern
                    CustomPaint(
                      size: Size(size.width, size.height * 0.28),
                      painter: _CarpetPatternPainter(),
                    ),
                    // Shine effect
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Curved transition to content area
            Positioned(
              top: size.height * 0.28 - 35,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 70),
                painter: _CurvedTransitionPainter(),
              ),
            ),
            
            // Subtle decorative elements in content area
            Positioned(
              bottom: 30,
              right: 20,
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  size: const Size(100, 100),
                  painter: _DiamondAccentPainter(),
                ),
              ),
            ),
            
            // AppBar with glassmorphism effect
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Back button with glass effect
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: onPressed,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Text(
                        titleScreen ?? 'title',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          shadows: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Optional actions
                    if (actions != null)
                      Row(mainAxisSize: MainAxisSize.min, children: actions!),
                  ],
                ),
              ),
            ),
            
            // Content
            Column(
              children: [
                SizedBox(height: Responsive.of(context).hp(8)),
                child ?? Container(),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Carpet-inspired geometric pattern painter
class _CarpetPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..style = PaintingStyle.fill;

    // Diamond grid pattern (carpet weaving inspiration)
    final patternSize = size.width / 10;
    for (double x = 0; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < size.height + patternSize; y += patternSize) {
        final offsetX = (y / patternSize).floor() % 2 == 0 ? 0.0 : patternSize / 2;
        _drawDiamond(canvas, Offset(x + offsetX, y), patternSize * 0.35, paint);
      }
    }

    // Accent diamonds
    final random = Random(42);
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      _drawDiamond(canvas, Offset(x, y), patternSize * 0.5, fillPaint);
    }

    // Subtle horizontal weave lines
    for (double y = 0; y < size.height; y += size.height / 10) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.white.withOpacity(0.015)
          ..strokeWidth = 1,
      );
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double diamondSize, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - diamondSize)
      ..lineTo(center.dx + diamondSize, center.dy)
      ..lineTo(center.dx, center.dy + diamondSize)
      ..lineTo(center.dx - diamondSize, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Curved transition painter
class _CurvedTransitionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colores.scaffoldBackgroundColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width / 2,
        0,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Diamond accent painter for subtle background decoration
class _DiamondAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colores.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Nested diamonds
    for (int i = 0; i < 4; i++) {
      final ratio = 1.0 - (i * 0.22);
      final diamondSize = size.width * ratio / 2;
      final center = Offset(size.width / 2, size.height / 2);
      
      final path = Path()
        ..moveTo(center.dx, center.dy - diamondSize)
        ..lineTo(center.dx + diamondSize, center.dy)
        ..lineTo(center.dx, center.dy + diamondSize)
        ..lineTo(center.dx - diamondSize, center.dy)
        ..close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
