import 'package:flutter/material.dart';

/// Layout responsivo para las pantallas de búsqueda
/// (Inventario Tienda, Bodegas, Búsqueda Global).
///
/// - **Ancho ≥ 900 px** (landscape phone, tablet, desktop): formulario fijo
///   en un sidebar a la izquierda (≈ 360 px) y resultados ocupando el
///   resto del espacio.
/// - **Ancho < 900 px** (portrait phone): barra "Filtros" **colapsable**.
///   Por defecto abierta; al tocar el header se colapsa para dar todo el
///   espacio a los resultados (antes el form ocupaba un alto fijo y no
///   dejaba ver los resultados).
///
/// Inspirado en el sidebar de filtros del web
/// (`F:\python\galeria\busquedaglobal.html`).
class BusquedaLayout extends StatefulWidget {
  /// Campos del formulario de búsqueda.
  final Widget form;

  /// Resultados (ej: `ProductosResultGrid` o un loader).
  final Widget results;

  /// Breakpoint en px para considerar la pantalla "ancha".
  final double sidebarBreakpoint;

  /// Ancho del sidebar cuando se usa modo ancho.
  final double sidebarWidth;

  /// Notifier opcional para controlar (y reaccionar) el estado abierto/
  /// colapsado del panel de filtros en modo angosto. La pantalla lo pone
  /// en `false` tras "Buscar" para auto-colapsar y mostrar resultados.
  final ValueNotifier<bool>? abiertoNotifier;

  const BusquedaLayout({
    super.key,
    required this.form,
    required this.results,
    this.sidebarBreakpoint = 900,
    this.sidebarWidth = 360,
    this.abiertoNotifier,
  });

  @override
  State<BusquedaLayout> createState() => _BusquedaLayoutState();
}

class _BusquedaLayoutState extends State<BusquedaLayout> {
  late final ValueNotifier<bool> _abierto =
      widget.abiertoNotifier ?? ValueNotifier<bool>(true);

  @override
  void dispose() {
    // Solo se dispone si lo creó este widget (no si vino del padre).
    if (widget.abiertoNotifier == null) _abierto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= widget.sidebarBreakpoint;

        if (wide) {
          // Sidebar fijo + resultados.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: widget.sidebarWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor
                        .withValues(alpha: 0.6),
                    border: Border(
                      right: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    child: widget.form,
                  ),
                ),
              ),
              Expanded(child: widget.results),
            ],
          );
        }

        // Angosto: header "Filtros" colapsable.
        // - Abierto: el form ocupa TODO el alto disponible y es
        //   scrolleable, así el botón "Buscar" siempre es alcanzable.
        // - Colapsado: los resultados ocupan toda la pantalla.
        // (Antes el form estaba en un área de ~45% y Buscar quedaba fuera.)
        return ValueListenableBuilder<bool>(
          valueListenable: _abierto,
          builder: (context, abierto, _) {
            return Column(
              children: [
                _FiltrosHeader(
                  abierto: abierto,
                  onToggle: () => _abierto.value = !_abierto.value,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: abierto
                      ? SingleChildScrollView(child: widget.form)
                      : widget.results,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FiltrosHeader extends StatelessWidget {
  final bool abierto;
  final VoidCallback onToggle;

  const _FiltrosHeader({required this.abierto, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.tune, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  abierto ? 'Ocultar' : 'Mostrar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: abierto ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
