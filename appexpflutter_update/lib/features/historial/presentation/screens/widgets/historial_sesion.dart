import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/pdf_viewer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class HistorialListSesion extends StatelessWidget {
  const HistorialListSesion(
      {super.key, required this.historial, required this.search});
  final List<HistorialSesionEntity> historial;
  final String search;

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
    return SizedBox(
      height: size.height * 0.72,
      child: ListView.builder(
        itemCount: historial.length,
        itemBuilder: (context, index) {
          final formattedDate =
              DateFormat('yyyy/MM/dd').format(historial[index].fecha);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 4,
              child: ListTile(
                onTap: () {
                  String pdfUrl =
                      'https://tapetestufan.mx/expo/${historial[index].idExpo}/pdf/${historial[index].pedidos}.pdf';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewerScreen(
                        fileName: historial[index].pedidos,
                        search: search,
                        url: pdfUrl,
                      ),
                    ),
                  );
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
                          offset: Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.userLarge,
                      color: Colores.secondaryColor,
                      size: 20,
                    ),
                  ),
                ),
                title: AutoSizeText(
                  historial[index].pedidos,
                  style: const TextStyle(
                      color: Colores.secondaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'Cliente: ${historial[index].nombre} ${historial[index].apellido}',
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
                          'Total: ${Utils.formatPrice(historial[index].totalPagar.toDouble())}',
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
}
