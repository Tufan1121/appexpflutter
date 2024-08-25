import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_galeria/detalle_galeria_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/galeria/galeria_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/screens/galeria_detail_screen.dart';
import 'package:appexpflutter_update/features/galeria/presentation/screens/widgets/search_gallery.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GaleriaScreen extends StatelessWidget {
  const GaleriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<GaleriaBloc>().add(ResetGaleriaEvent());
      },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<GaleriaBloc>().add(ResetGaleriaEvent());
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colores.secondaryColor.withOpacity(0.78),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'GALERIA',
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
              Column(
                children: [
                  const SearchGallery(),
                  const SizedBox(height: 10),
                  BlocBuilder<GaleriaBloc, GaleriaState>(
                    builder: (context, state) {
                      if (state is GaleriaLoading) {
                        return const Column(
                          children: [
                            SizedBox(height: 150),
                            Center(
                              child: CircularProgressIndicator(
                                color: Colores.secondaryColor,
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is GaleriaError) {
                        return Center(
                          child: Text(state.message),
                        );
                      }

                      if (state is GaleriaLoaded) {
                        return Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 20,
                            padding: const EdgeInsets.all(10.0),
                            children: state.galeria.map((galeria) {
                              return GestureDetector(
                                onTap: () async {
                                  final user =
                                      await SharedPreferences.getInstance();
                                  if (context.mounted) {
                                    context.read<DetalleGaleriaBloc>().add(
                                        GetProductEvent(
                                            descripcion: galeria.descripcio));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GaleriaDetailScreen(
                                          userName:
                                              user.getString('username') ?? '',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: FadeInImage(
                                          placeholder: const AssetImage(
                                              'assets/loaders/loading.gif'),
                                          width: double.infinity,
                                          height: 120,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/no-image.jpg',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                          fadeInDuration:
                                              const Duration(milliseconds: 300),
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(galeria.pathima1)}',
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          galeria.descripcio,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            color: Colores.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
