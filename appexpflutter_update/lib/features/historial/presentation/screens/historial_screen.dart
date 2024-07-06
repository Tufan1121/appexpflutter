import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/historial/presentation/bloc/historial_bloc.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/pdf_viewer.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/search_historial.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  Future<String> downloadFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final dio = Dio();

    try {
      await dio.download(url, filePath);
      return filePath;
    } catch (e) {
      // throw Exception('Error al descargar el archivo: $e');
      throw Exception(
          'Error al descargar el archivo $fileName tal vez no exista');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<HistorialBloc>().add(ClearHistorialEvent());
      },
      child: LayoutScreens(
        onPressed: () {
          context.read<HistorialBloc>().add(ClearHistorialEvent());
          Navigator.pop(context);
        },
        titleScreen: 'HISTORIAL',
        child: Column(
          children: [
            SearchHistorial(),
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
                  return SizedBox(
                    height: size.height * 0.72,
                    child: ListView.builder(
                      itemCount: state.historial.length,
                      itemBuilder: (context, index) {
                        final formattedDate = DateFormat('yyyy/MM/dd')
                            .format(state.historial[index].fecha);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            elevation: 4,
                            child: ListTile(
                              onTap: () async {
                                String pdfUrl =
                                    'https://tapetestufan.mx/expo/${state.historial[index].idExpo}/pdf/${state.historial[index].pedidos}.pdf';
                                try {
                                  final filePath = await downloadFile(pdfUrl,
                                      '${state.historial[index].pedidos}.pdf');
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerScreen(
                                          path: filePath,
                                          fileName:
                                              state.historial[index].pedidos,
                                          search: state.search,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            'Error al descargar el PDF: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              leading: Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                    color: Colores.scaffoldBackgroundColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 1,
                                        offset: Offset(
                                            0, 4), // changes position of shadow
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.userLarge,
                                    color: Colores.secondaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              title: AutoSizeText(
                                state.historial[index].pedidos,
                                style: const TextStyle(
                                    color: Colores.secondaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    'Cliente: ${state.historial[index].nombre} ${state.historial[index].apellido}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      AutoSizeText(
                                        'Total: ${Utils.formatPrice(state.historial[index].totalPagar.toDouble())}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
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
      ),
    );
  }
}
