import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'widgets/widgets.dart';

class ClienteNuevoScreen extends StatelessWidget {
  const ClienteNuevoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false, // Mantiene la imagen de fondo fija
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.4, 0.7],
              ),
            ),
          ),
          Column(
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(40.0),
                child: CustomAppBar(
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                  title: 'CLIENTE NUEVO',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 470,
                  child: Card(
                    elevation: 5,
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
