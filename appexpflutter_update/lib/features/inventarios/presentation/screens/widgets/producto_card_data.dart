import 'package:collection/collection.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';

/// Modelo de UI agrupado para tarjetas/detalle de producto.
///
/// Un `ProductoCardData` representa **un diseño** (ej: "LOGAN 01 CAFE") con
/// **N variantes** (una por cada medida disponible). Eso evita que el grid
/// muestre la misma foto repetida solo porque hay 3 medidas distintas.
class ProductoCardData {
  // Datos compartidos por todas las variantes del mismo diseño.
  final String descripcio;
  final String diseno;
  final String? composicion;
  final String? origen;
  final List<String> cuidados;
  final List<String> colores;
  final List<String> fotos;

  /// Textura/superficie para el visualizador "Ver en mi espacio". Si viene
  /// vacía (o null) el diseño no tiene visualizador y la card oculta el icono.
  final String? surface;

  // Variantes (1 por medida).
  final List<Variante> variantes;

  const ProductoCardData({
    required this.descripcio,
    required this.diseno,
    required this.composicion,
    required this.origen,
    required this.cuidados,
    required this.colores,
    required this.fotos,
    this.surface,
    required this.variantes,
  });

  /// `true` si el diseño trae superficie para visualizar en el espacio.
  bool get tieneVisualizador => (surface ?? '').trim().isNotEmpty;

  int get existenciaTotal =>
      variantes.fold<double>(0, (s, v) => s + v.existencia).toInt();

  bool get disponible => existenciaTotal > 0;

  // ───────────────────────────── ADAPTADORES (Tienda / Global) ─────────────

  /// Agrupa una lista de `ProductoExpoEntity` en cards por diseño.
  static List<ProductoCardData> groupExpo(Iterable<ProductoExpoEntity> items) {
    final groups = groupBy<ProductoExpoEntity, String>(
      items,
      (p) => '${p.descripcio.trim()}||${p.diseno.trim()}||${p.pathima1.trim()}',
    );
    return groups.values.map(_buildFromExpoGroup).toList();
  }

  static ProductoCardData _buildFromExpoGroup(List<ProductoExpoEntity> group) {
    final first = group.first;
    final byMedida =
        groupBy<ProductoExpoEntity, String>(group, (p) => p.medidas.trim());
    final variantes = byMedida.entries.map((entry) {
      final medidas = entry.key;
      final rows = entry.value;
      final f = rows.first;
      return Variante(
        claveCorta: f.producto1.trim(),
        claveLarga: f.producto.trim(),
        medidas: medidas,
        largo: f.largo,
        ancho: f.ancho,
        existencia: rows.fold<int>(0, (s, p) => s + p.hm),
        inventarioPorAlmacen: rows
            .map((p) => InventarioAlmacen(
                  nombre: '${p.almacen.trim()} - ${p.desalmacen.trim()}',
                  existencia: p.hm.toDouble(),
                ))
            .toList(),
        precio1: f.precio1,
        precio2: f.precio2,
        precio3: f.precio3,
        largop: f.largop,
        anchop: f.anchop,
        altop: f.altop,
        peso: f.peso,
      );
    }).toList()
      ..sort((a, b) => a.medidas.compareTo(b.medidas));

    return ProductoCardData(
      descripcio: first.descripcio.trim(),
      diseno: first.diseno.trim(),
      composicion:
          (first.compos ?? '').trim().isEmpty ? null : first.compos!.trim(),
      origen: (first.origen ?? '').trim().isEmpty ? null : first.origen!.trim(),
      cuidados: _noVacios([first.lava1, first.lava2]),
      colores: _noVacios([first.color1, first.color2, first.color3]),
      fotos: _fotosDe([
        first.pathima1,
        first.pathima2,
        first.pathima3,
        first.pathima4,
        first.pathima5,
        first.pathima6,
      ]),
      surface: first.surface,
      variantes: variantes,
    );
  }

  // ───────────────────────────── ADAPTADORES (Bodegas) ─────────────────────

  /// Agrupa una lista de `ProductoEntity` (Inventario Bodegas) en cards por
  /// diseño. Cada `Variante` mantiene sus 4 bodegas como ítems en
  /// `inventarioPorAlmacen`.
  static List<ProductoCardData> groupBodega(Iterable<ProductoEntity> items) {
    final groups = groupBy<ProductoEntity, String>(
      items,
      (p) => '${p.descripcio.trim()}||${p.diseno.trim()}||${p.pathima1.trim()}',
    );
    return groups.values.map(_buildFromBodegaGroup).toList();
  }

  static ProductoCardData _buildFromBodegaGroup(List<ProductoEntity> group) {
    final first = group.first;
    final byMedida =
        groupBy<ProductoEntity, String>(group, (p) => p.medidas.trim());
    final variantes = byMedida.entries.map((entry) {
      final medidas = entry.key;
      final rows = entry.value;
      final f = rows.first;
      double b1 = 0, b2 = 0, b3 = 0, b4 = 0;
      for (final r in rows) {
        b1 += r.bodega1;
        b2 += r.bodega2;
        b3 += r.bodega3;
        b4 += r.bodega4;
      }
      final total = (b1 + b2 + b3 + b4).toInt();
      return Variante(
        claveCorta: f.producto1.trim(),
        claveLarga: f.producto.trim(),
        medidas: medidas,
        largo: f.largo,
        ancho: f.ancho,
        existencia: total,
        inventarioPorAlmacen: [
          InventarioAlmacen(nombre: 'Bodega 1', existencia: b1),
          InventarioAlmacen(nombre: 'Bodega 2', existencia: b2),
          InventarioAlmacen(nombre: 'Bodega 3', existencia: b3),
          InventarioAlmacen(nombre: 'Bodega 4', existencia: b4),
        ],
        precio1: f.precio1,
        precio2: f.precio2,
        precio3: f.precio3,
        largop: f.largop,
        anchop: f.anchop,
        altop: f.altop,
        peso: f.peso,
      );
    }).toList()
      ..sort((a, b) => a.medidas.compareTo(b.medidas));

    final composicion = _noVacios([first.compo1, first.compo2]).join(', ');
    return ProductoCardData(
      descripcio: first.descripcio.trim(),
      diseno: first.diseno.trim(),
      composicion: composicion.isEmpty ? null : composicion,
      origen: first.origenn.trim().isEmpty ? null : first.origenn.trim(),
      cuidados: _noVacios([first.lava1, first.lava2]),
      colores: _noVacios([first.color1, first.color2, first.color3]),
      fotos: _fotosDe([
        first.pathima1,
        first.pathima2,
        first.pathima3,
        first.pathima4,
        first.pathima5,
        first.pathima6,
      ]),
      surface: first.surface,
      variantes: variantes,
    );
  }

  // ───────────────────────────── helpers ───────────────────────────────────

  static List<String> _fotosDe(List<String> raw) =>
      raw.where((p) => p.trim().isNotEmpty).toList();

  static List<String> _noVacios(Iterable<String?> xs) => xs
      .whereType<String>()
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

/// Una variante = una medida específica de un diseño con sus precios y
/// desglose de inventario. Para esta app solo se exponen precio1 (Normal),
/// precio2 (Expo) y precio3 (Mayoreo). `largop/anchop/altop/peso` solo vienen
/// para `ProductoEntity` (bodegas), no para `ProductoExpoEntity`.
class Variante {
  final String claveCorta;
  final String claveLarga;
  final String medidas;
  final double largo;
  final double ancho;
  final int existencia;
  final List<InventarioAlmacen> inventarioPorAlmacen;
  final int precio1;
  final int precio2;
  final int precio3;
  final double? largop;
  final double? anchop;
  final double? altop;
  final double? peso;

  const Variante({
    required this.claveCorta,
    required this.claveLarga,
    required this.medidas,
    required this.largo,
    required this.ancho,
    required this.existencia,
    required this.inventarioPorAlmacen,
    required this.precio1,
    required this.precio2,
    required this.precio3,
    this.largop,
    this.anchop,
    this.altop,
    this.peso,
  });

  /// `largop × anchop × altop m` si los 3 vienen, si no `null`.
  String? get empacado {
    if (largop == null || anchop == null || altop == null) return null;
    if (largop! <= 0 && anchop! <= 0 && altop! <= 0) return null;
    return '${largop!.toStringAsFixed(2)} × ${anchop!.toStringAsFixed(2)} × ${altop!.toStringAsFixed(2)} m';
  }

  /// Peso formateado como entero kg, o `null` si no hay dato.
  String? get pesoFmt {
    if (peso == null || peso! <= 0) return null;
    return '${peso!.round()} kg';
  }
}

class InventarioAlmacen {
  final String nombre;
  final double existencia;

  const InventarioAlmacen({required this.nombre, required this.existencia});
}
