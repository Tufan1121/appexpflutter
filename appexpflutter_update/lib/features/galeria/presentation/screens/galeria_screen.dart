import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_galeria/detalle_galeria_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/galeria/galeria_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/screens/galeria_detail_screen.dart';
import 'package:appexpflutter_update/features/galeria/presentation/screens/widgets/search_gallery.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GaleriaScreen extends StatefulWidget {
  const GaleriaScreen({super.key});

  @override
  State<GaleriaScreen> createState() => _GaleriaScreenState();
}

class _GaleriaScreenState extends State<GaleriaScreen> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1; // Página o límite inicial
  bool _isLoadingMore = false; // Control del indicador de carga adicional
  bool _hasMoreData = true; // Indica si hay más datos por cargar

  @override
  void initState() {
    super.initState();
    // Carga inicial de datos
    _fetchData();

    // Listener para detectar el final del scroll
    _scrollController.addListener(() {
      final galeriaBloc = context.read<GaleriaBloc>();

      // Desactivar scroll infinito si hay una búsqueda activa
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore &&
          _hasMoreData &&
          !galeriaBloc.isSearching) {
        _fetchData();
      }
    });
  }

  void _fetchData() {
    setState(() {
      _isLoadingMore = true;
    });

    // Llama al Bloc para obtener los datos de la siguiente página
    context.read<GaleriaBloc>().add(GetGaleriaEvent(regg: _page));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        context.read<GaleriaBloc>().add(ResetGaleriaEvent());
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                    child: PreferredSize(
                      preferredSize: const Size.fromHeight(40.0),
                      child: CustomAppBar(
                        backgroundColor: Colors.transparent,
                        color: Colors.white,
                        onPressed: () {
                          context.read<GaleriaBloc>().add(ResetGaleriaEvent());
                          Navigator.pop(context);
                        },
                        title: 'GALERÍA',
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const SearchGallery(),
                  const SizedBox(height: 10),
                  BlocBuilder<GaleriaBloc, GaleriaState>(
                    builder: (context, state) {
                      final galeriaBloc = context.read<GaleriaBloc>();

                      if (state is GaleriaLoading && _page == 1) {
                        return Column(
                          children: [
                            const SizedBox(height: 250),
                            Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
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
                        // Incrementar la página y desactivar la carga si no es búsqueda
                        if (!galeriaBloc.isSearching) {
                          _page++;
                          _isLoadingMore = false;

                          // Controlar si no hay más datos que cargar
                          if (state.galeria.isEmpty) {
                            _hasMoreData = false;
                          }
                        }

                        // En horizontal mostramos 5 columnas para aprovechar
                        // el ancho; en vertical 2 (default original). La
                        // relación 0.7 sirve bien para 2 columnas (cards más
                        // altas); con 5 columnas usamos 0.85 para que no
                        // queden demasiado altas.
                        final isLandscape =
                            MediaQuery.of(context).orientation ==
                                Orientation.landscape;
                        final crossAxisCount = isLandscape ? 5 : 2;
                        final aspectRatio = isLandscape ? 0.85 : 0.7;

                        return Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: aspectRatio,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            itemCount: state.galeria.length +
                                (_isLoadingMore && !galeriaBloc.isSearching
                                    ? 1
                                    : 0), // Mostrar indicador de carga si es necesario
                            itemBuilder: (context, index) {
                              if (index == state.galeria.length &&
                                  _isLoadingMore &&
                                  !galeriaBloc.isSearching) {
                                // Mostrar CircularProgressIndicator al final si está cargando más datos
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final galeria = state.galeria[index];
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
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/no-image.jpg',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.contain,
                                            );
                                          },
                                          fadeInDuration:
                                              const Duration(milliseconds: 300),
                                          fit: BoxFit.contain,
                                          image: NetworkImage(
                                            'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(galeria.pathima1)}',
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          galeria.descripcio,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
