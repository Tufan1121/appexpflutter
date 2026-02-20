import 'dart:math' show Random;
import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// Enhanced background painter with gradient and carpet-inspired patterns
/// for use in screens that need a premium header with curved transitions
class BackgroundPainter extends CustomPainter {
  final Color? color;
  final bool showPattern;

  BackgroundPainter({super.repaint, this.color, this.showPattern = true});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient header
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colores.gradientStart,
        Colores.gradientMiddle,
        Colores.gradientEnd,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.4);
    final paint = Paint()..shader = gradient.createShader(rect);

    final path = Path();
    path.moveTo(0, size.height * 0.38);
    path.quadraticBezierTo(
        size.width / 2, size.height * 0.28, size.width, size.height * 0.38);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Draw carpet-inspired diamond pattern overlay
    if (showPattern) {
      _drawCarpetPattern(canvas, size);
    }
  }

  void _drawCarpetPattern(Canvas canvas, Size size) {
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final patternSize = size.width / 12;
    final headerHeight = size.height * 0.35;

    for (double x = 0; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < headerHeight; y += patternSize) {
        final offsetX = (y / patternSize).floor() % 2 == 0 ? 0.0 : patternSize / 2;
        _drawDiamond(canvas, Offset(x + offsetX, y), patternSize * 0.3, patternPaint);
      }
    }

    // Add some subtle accent diamonds
    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 4; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * headerHeight * 0.8;
      _drawDiamond(canvas, Offset(x, y), patternSize * 0.45, fillPaint);
    }

    // Subtle weave lines
    for (double y = 0; y < headerHeight; y += headerHeight / 8) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.white.withOpacity(0.015)
          ..strokeWidth = 0.5,
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
