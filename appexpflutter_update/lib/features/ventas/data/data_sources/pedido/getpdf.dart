import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Getpdf {
  final Dio _dio;
  final BuildContext context;

  Getpdf({
    required this.context,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  Future<void> downloadPDF(String pdfUrl, nombrePdf) async {
    try {
      // Obtiene el directorio de descargas
      final downloadDir = Directory('/storage/emulated/0/Download');
      final filePath = '${downloadDir.path}/$nombrePdf.pdf';
      final response = await _dio.download(pdfUrl, filePath);

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'PDF descargado en $filePath',
              ),
              backgroundColor: Colors.green));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al descargar el PDF')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar el PDF: $e')),
        );
      }
    }
  }
}
