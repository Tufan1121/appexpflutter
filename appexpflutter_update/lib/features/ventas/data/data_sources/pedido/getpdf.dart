import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Getpdf {
  final Dio _dio;
  final BuildContext context;

  Getpdf({
    required this.context,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  Future<void> downloadPDF(String pdfUrl, nombrePdf) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final appDownloadsDir =
            Directory('/storage/emulated/0/Download/TufanApp');
        if (!await appDownloadsDir.exists()) {
          await appDownloadsDir.create(recursive: true);
        }
        final file = File('${appDownloadsDir.path}/$nombrePdf.pdf');
        await _dio.download(pdfUrl, file.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF descargado en ${file.path}'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al descargar el PDF: $e'),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de almacenamiento denegado'),
          ),
        );
      }
    }
  }
}
