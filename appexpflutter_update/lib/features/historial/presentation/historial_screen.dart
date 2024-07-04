import 'package:appexpflutter_update/features/historial/presentation/widgets/search_historial.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'HISTORIAL',
      child: const SearchHistorial(),
    );
  }
}

