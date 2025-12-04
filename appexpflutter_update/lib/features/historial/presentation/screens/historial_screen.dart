import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/historial/historial_bloc.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/historial_cotiza.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/search_historial.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        context.read<HistorialBloc>().add(ClearHistorialEvent());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Gradiente de fondo moderno
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colores.primaryColor.withValues(alpha: 0.05),
                    Colores.accentColor.withValues(alpha: 0.03),
                    Colores.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
            // Imagen de fondo con overlay
            Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/fondo.png',
                  ),
                  scale: 10,
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colores.scaffoldBackgroundColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(40.0),
                  child: CustomAppBar(
                    backgroundColor: Colors.transparent,
                    color: Colores.secondaryColor,
                    onPressed: () {
                      context.read<HistorialBloc>().add(ClearHistorialEvent());
                      Navigator.pop(context);
                    },
                    title: 'HISTORIAL',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: SearchHistorial(),
                ),
                const SizedBox(height: 6),
                BlocBuilder<HistorialBloc, HistorialState>(
                  builder: (context, state) {
                    if (state is HistorialLoading) {
                      return Column(
                        children: [
                          const SizedBox(height: 150),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colores.primaryColor.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              color: Colores.primaryColor,
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      );
                    }
                    if (state is HistorialCotizaLoaded) {
                      return HistorialListCotiza(
                          historial: state.historial, search: state.search);
                    }
                    if (state is HistorialError) {
                      return Column(
                        children: [
                          const SizedBox(height: 150),
                          Center(
                            child: SizedBox(
                              height: 60,
                              width: 300,
                              child: Card(
                                child: AutoSizeText(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Container();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
