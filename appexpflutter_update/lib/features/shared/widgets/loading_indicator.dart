import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Indicador de carga estándar de la app: tres puntos que rebotan
/// (`SpinKitThreeBounce`).
///
/// El color por defecto es el índigo de marca (visible sobre fondos claros).
/// Sobre el fondo índigo oscuro (búsquedas, cabeceras) pásale `Colors.white`.
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color ?? Colores.primaryColor,
      size: size,
    );
  }
}
