import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

/// Card moderno con efecto glassmorphism
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool enableGlass;
  final bool enableGradient;
  final Color? backgroundColor;
  final double? elevation;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.enableGlass = false,
    this.enableGradient = false,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        gradient: enableGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colores.gradientStart.withValues(alpha: 0.1),
                  Colores.gradientEnd.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: enableGlass
            ? Colors.white.withValues(alpha: 0.8)
            : (backgroundColor ?? Colores.cardColor),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enableGlass
              ? Colors.white.withValues(alpha: 0.3)
              : Colores.dividerColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: enableGlass
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colores.primaryColor.withValues(alpha: 0.1),
          highlightColor: Colores.primaryColor.withValues(alpha: 0.05),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Card de ítem para el home con animación y gradiente
class ModernItemCard extends StatefulWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final String? assetPathIcon;
  final List<Color>? gradientColors;

  const ModernItemCard({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.assetPathIcon,
    this.gradientColors,
  });

  @override
  State<ModernItemCard> createState() => _ModernItemCardState();
}

class _ModernItemCardState extends State<ModernItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ??
        [
          Colores.primaryColor.withValues(alpha: 0.1),
          Colores.accentColor.withValues(alpha: 0.05),
        ];

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colores.primaryColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colores.primaryColor.withValues(alpha: _isPressed ? 0.15 : 0.1),
                blurRadius: _isPressed ? 15 : 20,
                offset: Offset(0, _isPressed ? 2 : 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: Colores.primaryColor.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícono con efecto de fondo
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colores.primaryColor.withValues(alpha: 0.2),
                            Colores.accentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colores.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: widget.assetPathIcon != null
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                widget.assetPathIcon!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Icon(
                              widget.icon ?? Icons.star,
                              size: 32,
                              color: Colores.primaryColor,
                            ),
                    ),
                    const SizedBox(height: 12),
                    // Texto
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colores.textPrimary,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
