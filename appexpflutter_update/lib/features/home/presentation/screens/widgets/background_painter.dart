import 'dart:math' show Random;
import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

class BackgroundPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient header with dark slate colors
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

    // Draw subtle pattern overlay
    _drawPattern(canvas, size);
  }

  void _drawPattern(Canvas canvas, Size size) {
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
