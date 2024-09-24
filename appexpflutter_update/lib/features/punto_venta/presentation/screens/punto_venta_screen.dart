import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/card_item.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

class PuntoVentaScreen extends HookWidget {
  const PuntoVentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {},
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colores.secondaryColor.withOpacity(0.78),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'PUNTO DE VENTA',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colores.scaffoldBackgroundColor,
                  shadows: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2.0, 5.0),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: BackgroundPainter(),
            ),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 30,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(20.0),
              children: [
                CardItem(
                  icon: Icons.point_of_sale_sharp,
                  label: 'TICKETS',
                  onTap: () => TicketsRoute().push(context),
                ),
                CardItem(
                  icon: Icons.history_rounded,
                  label: 'CONSULTA',
                  onTap: () => HistorialRoute().push(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
