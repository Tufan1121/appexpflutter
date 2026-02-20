import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class ScanningAnimation extends StatefulWidget {
  const ScanningAnimation({super.key});

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animación rápida y repetitiva para simular un escáner
    _controller = AnimationController(
       duration: const Duration(milliseconds: 1500), 
       vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colores.secondaryColor.withOpacity(0.2),
              width: 2
            ),
            borderRadius: BorderRadius.circular(16)
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
               Icon(
                 Icons.qr_code_2,
                 size: 150,
                 color: Colores.secondaryColor.withOpacity(0.1),
               ),
               
               // Línea de escaneo animada
               AnimatedBuilder(
                 animation: _animation,
                 builder: (context, child) {
                   return Align(
                     alignment: Alignment(0, _animation.value),
                     child: Container(
                       width: 180, 
                       height: 4,
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           colors: [
                             Colors.redAccent.withOpacity(0),
                             Colors.redAccent,
                             Colors.redAccent.withOpacity(0),
                           ],
                         ),
                         borderRadius: BorderRadius.circular(2),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.redAccent.withOpacity(0.6),
                             blurRadius: 8,
                             spreadRadius: 2,
                           )
                         ]
                       ),
                     ),
                   );
                 },
               ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          child: const Column(
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colores.secondaryColor,
              ),
              SizedBox(height: 15),
              AutoSizeText(
                'Consultando precio...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colores.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
