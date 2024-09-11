import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/historial/historial_bloc.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/historial_cotiza.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/historial_pedido.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/historial_sesion.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/search_historial.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: CustomAppBar(
            onPressed: () {
              context.read<HistorialBloc>().add(ClearHistorialEvent());
              Navigator.pop(context);
            },
            title: 'HISTORIAL',
          ),
        ),
        body: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: BackgroundPainter(),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: SearchHistorial(),
                ),
                const SizedBox(height: 6),
                BlocBuilder<HistorialBloc, HistorialState>(
                  builder: (context, state) {
                    if (state is HistorialLoading) {
                      return const Column(
                        children: [
                          SizedBox(height: 150),
                          CircularProgressIndicator(
                            color: Colores.secondaryColor,
                          ),
                        ],
                      );
                    }
                    if (state is HistorialLoaded) {
                      return HistorialListPedido(
                          historial: state.historial, search: state.search);
                    }
                    if (state is HistorialSesionLoaded) {
                      return HistorialListSesion(
                          historial: state.historial, search: state.search);
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
