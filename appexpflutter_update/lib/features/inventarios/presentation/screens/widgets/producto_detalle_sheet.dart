import 'dart:io';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/producto_card_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

/// Bottom sheet de detalle de producto inspirado en el modal del web
/// (`F:\python\galeria\busquedaglobal.html`).
///
/// Estructura:
///   - Header sticky con clave corta + descripción + cerrar.
///   - Carrusel de fotos con thumbs y zoom (PhotoViewGallery).
///   - Grid Clave Corta / Clave Larga con botones de copiar (de la variante
///     activa).
///   - Chips selectoras de medida (variantes del mismo diseño).
///   - Grid Especificaciones (Medidas, País, Composición, Peso, Empacado,
///     Existencia total). Los campos sin dato muestran "—".
///   - Chips de Colores.
///   - Bullet list de Cuidados.
///   - Sección colapsable "Medidas y Precios en Existencia" con tabla de
///     precios por descuento de TODAS las variantes.
///   - Sección "Inventario por almacén" de la variante activa.
class ProductoDetalleSheet extends HookWidget {
  final ProductoCardData data;
  final int initialVarianteIndex;

  const ProductoDetalleSheet({
    super.key,
    required this.data,
    this.initialVarianteIndex = 0,
  });

  /// Abre el sheet usando `showModalBottomSheet`. Se permite ancho hasta
  /// 1100 px para aprovechar landscape / tablets / desktop.
  static Future<void> show(
    BuildContext context,
    ProductoCardData data, {
    int initialVarianteIndex = 0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      constraints: const BoxConstraints(maxWidth: 1100),
      builder: (_) => ProductoDetalleSheet(
        data: data,
        initialVarianteIndex: initialVarianteIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageController = usePageController();
    final currentPage = useState(0);
    final preciosOpen = useState(false);
    final activeVariante = useState(
      initialVarianteIndex.clamp(0, data.variantes.length - 1),
    );
    final active = data.variantes[activeVariante.value];

    // Secciones de datos (todo lo que NO es la galería). Se reutilizan en
    // modo angosto (todo en una columna scrolleable) y en modo ancho (la
    // galería va a la izquierda fija, estas secciones a la derecha
    // scrolleable).
    List<Widget> dataSections() => [
          _Claves(
            claveCorta: active.claveCorta,
            claveLarga: active.claveLarga,
          ),
          if (data.variantes.length > 1) ...[
            const SizedBox(height: 18),
            const _SectionTitle(
              icon: Icons.straighten,
              text: 'Medida',
            ),
            const SizedBox(height: 6),
            _MedidaChips(
              variantes: data.variantes,
              activeIndex: activeVariante.value,
              onSelect: (i) => activeVariante.value = i,
            ),
          ],
          const SizedBox(height: 18),
          _Especificaciones(data: data, activeVariante: active),
          if (data.colores.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionTitle(
              icon: Icons.palette_outlined,
              text: 'Colores',
            ),
            const SizedBox(height: 6),
            _ColoresChips(colores: data.colores),
          ],
          if (data.cuidados.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionTitle(
              icon: Icons.water_drop_outlined,
              text: 'Cuidados',
            ),
            const SizedBox(height: 6),
            _BulletList(items: data.cuidados),
          ],
          const SizedBox(height: 18),
          _PreciosToggle(
            variantes: data.variantes,
            activeIndex: activeVariante.value,
            open: preciosOpen.value,
            onToggle: () => preciosOpen.value = !preciosOpen.value,
          ),
          const SizedBox(height: 18),
          const _SectionTitle(
            icon: Icons.warehouse_outlined,
            text: 'Inventario por almacén',
          ),
          const SizedBox(height: 6),
          _InventarioList(items: active.inventarioPorAlmacen),
          const SizedBox(height: 24),
        ];

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, sheetController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _Header(
                title: active.claveCorta.isNotEmpty ? active.claveCorta : '—',
                subtitle: [
                  data.descripcio,
                  data.diseno,
                  active.medidas,
                ].where((e) => e.isNotEmpty).join(' · '),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 720;
                    final galeria = _Galeria(
                      fotos: data.fotos,
                      pageController: pageController,
                      currentPage: currentPage,
                    );

                    if (wide) {
                      // ─── Layout ancho: 2 columnas ───
                      // Izquierda: galería fija (con su altura limitada al
                      // alto disponible para que no rompa el layout).
                      // Derecha: secciones de datos en scroll.
                      final leftWidth = constraints.maxWidth * 0.45;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: leftWidth,
                              child: galeria,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: sheetController,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: dataSections(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ─── Layout angosto: todo en una columna ───
                    return CustomScrollView(
                      controller: sheetController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              galeria,
                              const SizedBox(height: 16),
                              ...dataSections(),
                            ]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets privados
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _Galeria extends StatelessWidget {
  final List<String> fotos;
  final PageController pageController;
  final ValueNotifier<int> currentPage;

  const _Galeria({
    required this.fotos,
    required this.pageController,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (fotos.isEmpty) {
      return _placeholder(theme);
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // PageView maneja el swipe horizontal entre fotos cuando no
                // hay zoom. InteractiveViewer en cada página maneja
                // pinch-to-zoom + pan cuando hay zoom. Mientras la escala
                // sea 1 no captura el pan, así que el PageView recibe el
                // swipe sin conflicto.
                Positioned.fill(
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: fotos.length,
                      onPageChanged: (i) => currentPage.value = i,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: 'pd-${fotos[index]}',
                          child: InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 4.0,
                            clipBehavior: Clip.none,
                            child: Image.network(
                              _urlFoto(fotos[index]),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Center(
                                child: Image.asset(
                                  'assets/images/no-image.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              loadingBuilder: (_, child, loading) {
                                if (loading == null) return child;
                                return Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                      value: loading.expectedTotalBytes == null
                                          ? null
                                          : loading.cumulativeBytesLoaded /
                                              loading.expectedTotalBytes!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Botones flotantes sobre la foto activa.
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _OverlayIconBtn(
                        icon: Icons.share,
                        tooltip: 'Compartir esta foto',
                        onPressed: () => compartirFoto(
                          context,
                          fotos[currentPage.value.clamp(0, fotos.length - 1)],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _OverlayIconBtn(
                        icon: Icons.fullscreen,
                        tooltip: 'Ver en pantalla completa',
                        onPressed: () => _openLightbox(context),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ValueListenableBuilder<int>(
                    valueListenable: currentPage,
                    builder: (_, i, __) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${i + 1} / ${fotos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (fotos.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (_, current, __) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: fotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final active = i == current;
                  return GestureDetector(
                    onTap: () => pageController.jumpToPage(i),
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: active ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/loaders/loading.gif',
                        image: _urlFoto(fotos[i]),
                        fit: BoxFit.cover,
                        imageErrorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/no-image.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _placeholder(ThemeData theme) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 48, color: Colors.grey),
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _Lightbox(
          fotos: fotos,
          initialIndex: currentPage.value,
        ),
      ),
    );
  }
}

class _Lightbox extends StatefulWidget {
  final List<String> fotos;
  final int initialIndex;

  const _Lightbox({required this.fotos, required this.initialIndex});

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _index = widget.initialIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.fotos.length}',
            style: const TextStyle(fontSize: 14)),
        actions: [
          IconButton(
            tooltip: 'Compartir esta foto',
            icon: const Icon(Icons.share),
            onPressed: () => compartirFoto(context, widget.fotos[_index]),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        pageController: _controller,
        itemCount: widget.fotos.length,
        onPageChanged: (i) => setState(() => _index = i),
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        builder: (_, i) => PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(_urlFoto(widget.fotos[i])),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          heroAttributes: PhotoViewHeroAttributes(tag: 'pd-${widget.fotos[i]}'),
        ),
      ),
    );
  }
}

/// Botón flotante semitransparente para overlays sobre fotos.
class _OverlayIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _OverlayIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _Claves extends StatelessWidget {
  final String claveCorta;
  final String claveLarga;
  const _Claves({required this.claveCorta, required this.claveLarga});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _claveItem(context, 'Clave corta', claveCorta)),
        const SizedBox(width: 16),
        Expanded(child: _claveItem(context, 'Clave larga', claveLarga)),
      ],
    );
  }

  Widget _claveItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (value.isNotEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copiado: $value'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Tooltip(
                    message: 'Copiar',
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            if (value.isNotEmpty) const SizedBox(width: 4),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: GoogleFonts.firaMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MedidaChips extends StatelessWidget {
  final List<Variante> variantes;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const _MedidaChips({
    required this.variantes,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < variantes.length; i++)
          InkWell(
            onTap: () => onSelect(i),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
              decoration: BoxDecoration(
                color: i == activeIndex
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: i == activeIndex
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    variantes[i].medidas.isEmpty ? '—' : variantes[i].medidas,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i == activeIndex
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: i == activeIndex
                          ? Colors.white.withValues(alpha: 0.25)
                          : theme.disabledColor.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      variantes[i].existencia.toString(),
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
          ),
      ],
    );
  }
}

class _Especificaciones extends StatelessWidget {
  final ProductoCardData data;
  final Variante activeVariante;
  const _Especificaciones({required this.data, required this.activeVariante});

  @override
  Widget build(BuildContext context) {
    final medidas =
        activeVariante.medidas.isEmpty ? '—' : activeVariante.medidas;
    final origen = (data.origen ?? '').isEmpty ? '—' : data.origen!;
    final composicion =
        (data.composicion ?? '').isEmpty ? '—' : data.composicion!;
    final peso = activeVariante.pesoFmt ?? '—';
    final empacado = activeVariante.empacado ?? '—';
    final existencia = activeVariante.existencia == 0
        ? '0 pza'
        : '${activeVariante.existencia} pza';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.straighten, text: 'Especificaciones'),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 480 ? 3 : 2;
            return Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _specCell(context, 'Medidas', medidas),
                _specCell(context, 'País de origen', origen),
                _specCell(context, 'Composición', composicion),
                _specCell(context, 'Peso', peso),
                _specCell(context, 'Empacado', empacado),
                _specCell(
                  context,
                  'Existencia total',
                  existencia,
                  highlight: activeVariante.existencia > 0,
                ),
              ]
                  .map((w) => SizedBox(
                        width: (c.maxWidth - (cols - 1) * 12) / cols,
                        child: w,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _specCell(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: highlight ? Colors.green.shade600 : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _ColoresChips extends StatelessWidget {
  final List<String> colores;
  const _ColoresChips({required this.colores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: colores
          .map((c) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 8, left: 4),
                      child: Icon(Icons.circle, size: 5),
                    ),
                    Expanded(
                      child: Text(t, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _PreciosToggle extends StatelessWidget {
  final List<Variante> variantes;
  final int activeIndex;
  final bool open;
  final VoidCallback onToggle;

  const _PreciosToggle({
    required this.variantes,
    required this.activeIndex,
    required this.open,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.payments_outlined,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'MEDIDAS Y PRECIOS EN EXISTENCIA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Icon(open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          if (open)
            _PreciosTabla(
              variantes: variantes,
              activeIndex: activeIndex,
            ),
        ],
      ),
    );
  }
}

/// Tabla custom de precios. Uso `Row + Expanded + TextAlign.end` en vez de
/// `DataTable` porque DataTable no respeta la alineación a la derecha en las
/// celdas (las columnas se dimensionan al contenido y la columna de precio
/// quedaba visualmente pegada a la izquierda).
class _PreciosTabla extends StatelessWidget {
  final List<Variante> variantes;
  final int activeIndex;

  const _PreciosTabla({required this.variantes, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7);
    final selectedBg = theme.colorScheme.primary.withValues(alpha: 0.10);

    List<({String label, int precio})> preciosDe(Variante v) => [
          (label: 'Normal', precio: v.precio1),
          (label: 'Expo', precio: v.precio2),
          (label: 'Mayoreo', precio: v.precio3),
        ];

    String money(int n) => Utils.formatPrice(n.toDouble());

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < variantes.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: i == activeIndex ? selectedBg : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variantes[i].medidas.isEmpty ? '—' : variantes[i].medidas,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  for (final p in preciosDe(variantes[i]))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            child: Text(
                              p.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: mutedColor,
                              ),
                            ),
                          ),
                          Text(
                            money(p.precio),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InventarioList extends StatelessWidget {
  final List<InventarioAlmacen> items;
  const _InventarioList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child:
            const Text('Sin inventario', style: TextStyle(color: Colors.grey)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.warehouse_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items[i].nombre,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    items[i]
                        .existencia
                        .toStringAsFixed(items[i].existencia % 1 == 0 ? 0 : 2),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: items[i].existencia > 0
                          ? Colors.green.shade600
                          : theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1)
              Divider(height: 1, color: theme.dividerColor),
          ],
        ],
      ),
    );
  }
}

String _urlFoto(String path) =>
    'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(path)}';

/// Descarga la imagen con marca de agua del backend y abre la hoja nativa
/// de compartir. Visible para que la usen el sheet y el lightbox.
Future<void> compartirFoto(BuildContext context, String imageUrl) async {
  if (imageUrl.trim().isEmpty) return;
  final dio = Dio();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      duration: Duration(seconds: 30),
      content: Row(children: [
        SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(width: 12),
        Text('Preparando imagen con marca de agua...'),
      ]),
    ),
  );
  try {
    Directory appDir;
    try {
      appDir = await getTemporaryDirectory();
    } catch (_) {
      appDir = await getApplicationDocumentsDirectory();
    }
    final fileName = imageUrl.split('/').last;
    final ext = fileName.contains('.') ? fileName : '$fileName.jpg';
    final file = File(
        '${appDir.path}/share_${DateTime.now().millisecondsSinceEpoch}_$ext');

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final originalUrl = 'https://tapetestufan.mx/imagen/_web/$imageUrl';
    final response = await dio.post(
      'https://api.tapetestufan.mx/add-watermark/',
      queryParameters: {'image_url': originalUrl},
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Authorization': 'Bearer $token'},
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    await file.writeAsBytes(response.data as List<int>);
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    await Share.shareXFiles([XFile(file.path, mimeType: 'image/jpeg')]);
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (await file.exists()) await file.delete();
    } catch (_) {}
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error al compartir: $e'),
      ));
    }
  }
}
