import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/producto_card_data.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/producto_detalle_sheet.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/visualizar_tapete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card de un resultado de búsqueda, inspirada en el grid del web
/// (`F:\python\galeria\busquedaglobal.html:1809-1840`).
///
/// Una card agrupa todas las medidas del mismo diseño (ver
/// `ProductoCardData.groupExpo` / `groupBodega`). Las medidas se muestran
/// como pills clickeables; la pill activa define qué clave / precio /
/// inventario se ve. El botón "Ver +Detalle" (abajo a la derecha) abre el
/// sheet de detalle con la variante activa pre-seleccionada.
class ProductoResultCard extends HookWidget {
  final ProductoCardData data;
  final VoidCallback? onTap;

  const ProductoResultCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeIndex = useState(0);
    final togglePrecio = useState(false);
    final active = data.variantes[activeIndex.value];

    void openSheet() {
      if (onTap != null) {
        onTap!();
      } else {
        ProductoDetalleSheet.show(
          context,
          data,
          initialVarianteIndex: activeIndex.value,
        );
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Thumb(
            data: data,
            onVisualizar: () => VisualizarTapete.iniciar(
              context,
              tapeteUrl: data.fotos.isEmpty ? '' : data.fotos.first,
              anchoM: active.ancho,
              largoM: active.largo,
              titulo: [
                data.descripcio,
                data.diseno,
                active.medidas,
              ].where((e) => e.isNotEmpty).join(' · '),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.descripcio.isEmpty ? '—' : data.descripcio,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.diseno.isEmpty ? '—' : data.diseno,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '· ${data.variantes.length} medida'
                      '${data.variantes.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                if ((data.origen ?? '').isNotEmpty ||
                    (data.composicion ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      [
                        if ((data.origen ?? '').isNotEmpty) data.origen,
                        if ((data.composicion ?? '').isNotEmpty)
                          data.composicion,
                      ].whereType<String>().join(' · '),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 6),
                _MedidaPills(
                  variantes: data.variantes,
                  activeIndex: activeIndex.value,
                  onSelect: (i) => activeIndex.value = i,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (active.claveCorta.isNotEmpty) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          await Clipboard.setData(
                              ClipboardData(text: active.claveCorta));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copiado: ${active.claveCorta}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 1),
                          child: Tooltip(
                            message: 'Copiar',
                            child: Icon(
                              Icons.copy,
                              size: 13,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        active.claveCorta.isEmpty ? '—' : active.claveCorta,
                        style: GoogleFonts.firaMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PriceFooter(
                        variante: active,
                        showPrice: togglePrecio.value,
                        onTogglePrice: () =>
                            togglePrecio.value = !togglePrecio.value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _VerDetalleButton(onTap: openSheet),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final ProductoCardData data;
  final VoidCallback onVisualizar;
  const _Thumb({required this.data, required this.onVisualizar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstFoto = data.fotos.isEmpty ? null : data.fotos.first;
    return Stack(
      children: [
        AspectRatio(
          // 1.25 = imagen ~20% más baja que el cuadrado (1.0) anterior:
          // alto = ancho / 1.25 = 0.8 × ancho.
          aspectRatio: 1.25,
          child: Container(
            color: theme.colorScheme.surface,
            child: firstFoto == null
                ? Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: theme.disabledColor, size: 40),
                  )
                : FadeInImage.assetNetwork(
                    placeholder: 'assets/loaders/loading.gif',
                    image:
                        'https://tapetestufan.mx:446/imagen/${Uri.encodeFull(firstFoto)}',
                    fit: BoxFit.cover,
                    imageErrorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/no-image.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _Badge(disponible: data.disponible),
        ),
        // Botón "Ver en mi espacio" (visualizador con foto del cliente).
        // Solo si el tapete tiene imagen.
        if (firstFoto != null)
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onVisualizar,
                child: const Tooltip(
                  message: 'Ver en mi espacio',
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(Icons.weekend_outlined,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Botón "Ver +Detalle" (abajo a la derecha de la card). Reemplaza al tap
/// en cualquier lado para abrir la ficha de detalle.
class _VerDetalleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _VerDetalleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.zoom_in, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Ver +Detalle',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool disponible;
  const _Badge({required this.disponible});

  @override
  Widget build(BuildContext context) {
    final color = disponible ? Colors.green.shade500 : Colors.grey.shade500;
    final text = disponible ? 'Disponible' : 'Agotado';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MedidaPills extends StatelessWidget {
  final List<Variante> variantes;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const _MedidaPills({
    required this.variantes,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < variantes.length; i++)
          _Pill(
            variante: variantes[i],
            active: i == activeIndex,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final Variante variante;
  final bool active;
  final VoidCallback onTap;

  const _Pill({
    required this.variante,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = active
        ? theme.colorScheme.primary.withValues(alpha: 0.15)
        : theme.colorScheme.surface;
    final border = active
        ? theme.colorScheme.primary.withValues(alpha: 0.55)
        : theme.dividerColor;
    final fg = active
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 3, 4, 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              variante.medidas.isEmpty ? '—' : variante.medidas,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: fg,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: active
                    ? theme.colorScheme.primary
                    : theme.disabledColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                variante.existencia.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceFooter extends StatelessWidget {
  final Variante variante;
  final bool showPrice;
  final VoidCallback onTogglePrice;

  const _PriceFooter({
    required this.variante,
    required this.showPrice,
    required this.onTogglePrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7);

    // El Precio de Lista se muestra siempre; estos 7 escalones de descuento
    // van dentro del desplegable "Promoción".
    final descuentos = <({String label, int precio})>[
      (label: '-20%', precio: variante.precio8),
      (label: '-25%', precio: variante.precio9),
      (label: '-30%', precio: variante.precio4),
      (label: '-35%', precio: variante.precio10),
      (label: '-40%', precio: variante.precio5),
      (label: '-50%', precio: variante.precio6),
      (label: '-70%', precio: variante.precio7),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Precio de Lista (siempre visible).
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Precio de Lista',
              style: TextStyle(fontSize: 11, color: mutedColor),
            ),
            Text(
              _formatMoney(variante.precio1),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        // Desplegable "Promoción" con los precios de descuento.
        InkWell(
          onTap: onTogglePrice,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Promoción',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colores.secondaryColor,
                  ),
                ),
                Icon(
                  showPrice
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colores.secondaryColor,
                ),
              ],
            ),
          ),
        ),
        if (showPrice)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final d in descuentos)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            d.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: mutedColor,
                            ),
                          ),
                        ),
                        Text(
                          _formatMoney(d.precio),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatMoney(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '\$$buf';
  }
}
