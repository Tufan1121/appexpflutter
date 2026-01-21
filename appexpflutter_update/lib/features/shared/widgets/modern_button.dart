import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

/// Bot├│n moderno con gradiente y animaciones
class ModernButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isGradient;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const ModernButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isGradient = true,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
    this.width,
    this.padding,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    if (widget.isOutlined) {
      return _buildOutlinedButton();
    }
    return _buildFilledButton();
  }

  Widget _buildFilledButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
          onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
          onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: 56,
              decoration: BoxDecoration(
                gradient: widget.isGradient
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colores.gradientStart,
                          Colores.gradientMiddle,
                          Colores.gradientEnd,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      )
                    : null,
                color: widget.isGradient ? null : Colores.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.onPressed != null
                    ? [
                        BoxShadow(
                          color: Colores.primaryColor.withOpacity(_isHovered ? 0.4 : 0.3),
                          blurRadius: _isHovered ? 30 : 24,
                          offset: Offset(0, _isHovered ? 16 : 12),
                          spreadRadius: _isHovered ? 2 : 0,
                        ),
                        BoxShadow(
                          color: Colores.gradientEnd.withOpacity(_isHovered ? 0.3 : 0.2),
                          blurRadius: _isHovered ? 20 : 16,
                          offset: Offset(0, _isHovered ? 8 : 6),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Padding(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: widget.isLoading
                        ? const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  widget.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
          onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
          onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: 56,
              decoration: BoxDecoration(
                color: _isHovered 
                    ? Colores.primaryColor.withOpacity(0.05) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colores.primaryColor,
                  width: 2,
                ),
                boxShadow: _isHovered
                    ? [
                         BoxShadow(
                          color: Colores.primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colores.primaryColor.withOpacity(0.1),
                  highlightColor: Colores.primaryColor.withOpacity(0.05),
                  child: Padding(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: widget.isLoading
                        ? const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colores.primaryColor),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: Colores.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  widget.text,
                                  style: const TextStyle(
                                    color: Colores.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

