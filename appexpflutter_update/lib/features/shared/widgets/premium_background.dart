import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

/// Premium background widget that creates a beautiful, consistent visual identity
/// across all screens, inspired by the patterns of rugs and carpets (tapetes y alfombras).
/// Features: 
/// - Animated gradient background with brand colors
/// - Subtle geometric patterns reminiscent of carpet weaving
/// - Glassmorphism effects for modern appeal
class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool showPattern;
  final bool isFullScreen;
  final double headerHeight;
  
  const PremiumBackground({
    super.key, 
    required this.child,
    this.showPattern = true,
    this.isFullScreen = false,
    this.headerHeight = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colores.scaffoldBackgroundColor,
            Colores.scaffoldBackgroundColor.withOpacity(0.95),
            Colors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Header gradient section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: isFullScreen ? size.height : size.height * headerHeight,
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
              child: showPattern 
                ? Stack(
                    children: [
                      // Carpet pattern overlay
                      CustomPaint(
                        size: Size(size.width, isFullScreen ? size.height : size.height * headerHeight),
                        painter: _CarpetPatternPainter(),
                      ),
                      // Subtle shine effect
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
            ),
          ),
          
          // Curved transition
          if (!isFullScreen)
            Positioned(
              top: size.height * headerHeight - 40,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 80),
                painter: _CurvedDividerPainter(),
              ),
            ),
            
          // Decorative corner elements
          if (showPattern) ...[
            Positioned(
              bottom: 20,
              right: 20,
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  size: const Size(120, 120),
                  painter: _DiamondPatternPainter(),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 10,
              child: Opacity(
                opacity: 0.02,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: _DiamondPatternPainter(),
                ),
              ),
            ),
          ],
          
          // Content
          child,
        ],
      ),
    );
  }
}

/// A header-only version for screens that don't need full-screen background
class PremiumHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottom;
  
  const PremiumHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppBar section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  leading ?? const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (actions != null)
                    Row(mainAxisSize: MainAxisSize.min, children: actions!)
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            if (bottom != null) bottom!,
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Glassmorphism card widget for consistent styling
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool hasShadow;
  final bool showAccentBorder;
  
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.backgroundColor,
    this.hasShadow = true,
    this.showAccentBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showAccentBorder ? Border.all(
          color: Colores.accentGradientStart.withOpacity(0.2),
          width: 1.5,
        ) : Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: hasShadow ? [
          // Sombra única, suave y neutra (pulido "Nocturno")
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

/// Gradient icon container matching the app's design language
class GradientIconContainer extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final double size;
  final double iconSize;
  
  const GradientIconContainer({
    super.key,
    this.icon,
    this.assetPath,
    this.size = 56,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colores.accentGradientStart, // Indigo
            Colores.accentGradientMiddle, // Purple  
            Colores.accentGradientEnd, // Pink
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.35),
        boxShadow: [
          BoxShadow(
            color: Colores.accentGradientStart.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colores.accentGradientEnd.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: assetPath != null
            ? Image.asset(
                assetPath!,
                width: iconSize,
                height: iconSize,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              )
            : Icon(
                icon ?? Icons.star,
                size: iconSize,
                color: Colors.white,
              ),
      ),
    );
  }
}

/// Paints carpet-inspired geometric patterns
class _CarpetPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw diamond grid pattern (reminiscent of carpet patterns)
    final patternSize = size.width / 8;
    for (double x = 0; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < size.height + patternSize; y += patternSize) {
        final offsetX = (y / patternSize).floor() % 2 == 0 ? 0.0 : patternSize / 2;
        _drawDiamond(canvas, Offset(x + offsetX, y), patternSize * 0.4, paint);
      }
    }

    // Draw some larger accent diamonds
    final random = Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 6; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      _drawDiamond(canvas, Offset(x, y), patternSize * 0.6, fillPaint);
    }

    // Draw subtle horizontal lines (like carpet weaving)
    for (double y = 0; y < size.height; y += size.height / 12) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.white.withOpacity(0.02)
          ..strokeWidth = 1,
      );
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints the curved divider between header and content
class _CurvedDividerPainter extends CustomPainter {
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

/// Diamond pattern for background decoration
class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colores.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Nested diamonds
    for (int i = 0; i < 4; i++) {
      final ratio = 1.0 - (i * 0.25);
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

/// Gradient text widget for consistent branding
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Colores.gradientStart,
          Colores.gradientMiddle,
          Colores.gradientEnd,
        ],
      ).createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

/// Section title with gradient accent
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colores.gradientStart,
                    Colores.gradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colores.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Colores.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Price display with gradient styling for premium feel
class PremiumPriceDisplay extends StatelessWidget {
  final double price;
  final String? label;
  final bool isLarge;
  final Color? color;
  
  const PremiumPriceDisplay({
    super.key,
    required this.price,
    this.label,
    this.isLarge = false,
    this.color,
  });

  String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              color: Colores.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ShaderMask(
          shaderCallback: color != null 
            ? (bounds) => LinearGradient(colors: [color!, color!]).createShader(bounds)
            : (bounds) => const LinearGradient(
              colors: [
                Colores.gradientStart,
                Colores.gradientEnd,
              ],
            ).createShader(bounds),
          child: Text(
            _formatPrice(price),
            style: TextStyle(
              fontSize: isLarge ? 28 : 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Status badge with gradient background
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  
  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.info,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case StatusType.success:
        color = Colores.successColor;
        break;
      case StatusType.warning:
        color = Colores.warningColor;
        break;
      case StatusType.error:
        color = Colores.errorColor;
        break;
      case StatusType.info:
      default:
        color = Colores.primaryColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

enum StatusType { success, warning, error, info }
