import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/sugerencias_calidad.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/features/inventarios/data/data_sources/inventario_expo_data_source.dart';

/// Widget que muestra el bloque "¿Quiso decir?" con sugerencias de calidad.
///
/// Recibe la calidad que tipeó el usuario (`descripcio`) y un callback que se
/// dispara cuando elige una sugerencia (típicamente: setear el form y volver
/// a ejecutar la búsqueda).
///
/// Comportamiento:
/// - Carga `/calidades/` una sola vez por sesión (cache estático).
/// - Calcula sugerencias con `SugerenciasCalidad.sugerir`.
/// - Si no hay sugerencias o `descripcio` está vacío, no renderiza nada.
class QuisoDecir extends StatefulWidget {
  final String descripcio;
  final ValueChanged<String> onSelected;

  const QuisoDecir({
    super.key,
    required this.descripcio,
    required this.onSelected,
  });

  @override
  State<QuisoDecir> createState() => _QuisoDecirState();
}

class _QuisoDecirState extends State<QuisoDecir> {
  static List<String>? _calidadesCache;
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCalidades();
  }

  Future<List<String>> _loadCalidades() async {
    if (_calidadesCache != null) return _calidadesCache!;
    final ds = GetIt.instance<InventarioExpoDataSource>();
    final list = await ds.getCalidades();
    _calidadesCache = list;
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.descripcio.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<String>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final sugerencias =
            SugerenciasCalidad.sugerir(widget.descripcio, snap.data!);
        if (sugerencias.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        sugerencias.length == 1
                            ? '¿Quiso decir?'
                            : '¿Quiso decir alguna de estas?',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sugerencias
                        .map((s) => ActionChip(
                              label: Text(s),
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              side: BorderSide(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.4),
                              ),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              onPressed: () => widget.onSelected(s),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
