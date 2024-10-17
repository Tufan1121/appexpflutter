import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/widgets/cliente_form.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class ClienteNuevoVentaScreen extends StatelessWidget {
  const ClienteNuevoVentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false, // Mantiene la imagen de fondo fija
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/fondo.png',
                ),
                fit: BoxFit
                    .cover, // Asegura que la imagen de fondo se vea completa
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              PreferredSize(
                preferredSize: const Size.fromHeight(40.0),
                child: CustomAppBar(
                  backgroundColor: Colors.transparent,
                  color: Colores.secondaryColor,
                  title: 'DATOS CLIENTE',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 410,
                  child: Card(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: size.height * 0.70,
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 20),
                              Flexible(flex: 1, child: ClienteForm()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
