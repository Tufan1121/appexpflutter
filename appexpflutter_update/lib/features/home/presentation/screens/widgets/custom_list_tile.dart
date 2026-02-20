import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  const CustomListTile({
    super.key,
    this.text,
    this.onTap,
    this.icon,
    this.assetPathIcon,
  });
  
  final String? text;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? assetPathIcon;

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0, // Subtle scale
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
          onTapUp: widget.onTap != null ? (_) => _controller.reverse() : null,
          onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.05),
                    blurRadius: _isHovered ? 15 : 10,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colores.primaryColor.withOpacity(0.1),
                  highlightColor: Colores.primaryColor.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Icon with gradient background
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colores.gradientStart,
                                Colores.gradientMiddle,
                                Colores.gradientEnd,
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colores.primaryColor.withOpacity(_isHovered ? 0.4 : 0.3),
                                blurRadius: _isHovered ? 15 : 12,
                                offset: Offset(0, _isHovered ? 5 : 4),
                              ),
                            ],
                          ),
                          child: widget.assetPathIcon != null
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    widget.assetPathIcon ?? '',
                                    color: Colors.white,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                )
                              : Icon(
                                  widget.icon,
                                  size: 24,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(width: 16),
                        // Text
                        Expanded(
                          child: Text(
                            widget.text ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colores.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        // Arrow icon
                        AnimatedPadding(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.only(left: _isHovered ? 5 : 0),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colores.textTertiary,
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

