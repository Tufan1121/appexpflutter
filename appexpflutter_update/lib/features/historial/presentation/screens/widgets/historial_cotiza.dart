import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/historial/domain/entities/historial_cotiza_entity.dart';
import 'package:appexpflutter_update/features/historial/presentation/screens/widgets/pdf_viewer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialListCotiza extends StatelessWidget {
  const HistorialListCotiza(
      {super.key, required this.historial, required this.search});
  final List<HistorialCotizaEntity> historial;
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colores.dividerColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colores.primaryColor.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String pdfUrl =
                      'https://tapetestufan.mx/cotiza/${prefs.getString('digsig')}/pdf/${historial[index].pedidos}.pdf';
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          fileName: historial[index].pedidos,
                          search: search,
                          userName: prefs.getString('username') ??
                              historial[index].nombre,
                          clientPhoneNumber: historial[index].telefono,
                          url: pdfUrl,
                        ),
                      ),
                    );
                  }
                },
                leading: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colores.secondaryColor.withValues(alpha: 0.12),
                        Colores.primaryColor.withValues(alpha: 0.12),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colores.secondaryColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.userLarge,
                      color: Colores.secondaryColor,
                      size: 22,
                    ),
                  ),
                ),
                title: AutoSizeText(
                  historial[index].pedidos,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colores.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    AutoSizeText(
                      'Cliente: ${historial[index].nombre} ${historial[index].apellido}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colores.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colores.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        AutoSizeText(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colores.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money_rounded,
                          size: 14,
                          color: Colores.successColor,
                        ),
                        const SizedBox(width: 4),
                        AutoSizeText(
                          Utils.formatPrice(historial[index].totalPagar.toDouble()),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colores.successColor,
                            fontWeight: FontWeight.w600,
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
