import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

/// Colores de las series, iguales a la lista de pedidos web (listaexpo).
const Color kColorPedidos = Color(0xFF2A78D6);
const Color kColorTickets = Color(0xFFEB6834);
const Color kColorBorde = Color(0xFFE3E7EF);
const Color kColorTextoTenue = Color(0xFF64748B);
const Color kColorTexto = Color(0xFF1E293B);

final NumberFormat fmtMoney =
    NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0);
final NumberFormat _fmtCompact =
    NumberFormat.compactCurrency(locale: 'en_US', symbol: '\$', decimalDigits: 1);

String fmtK(double v) => _fmtCompact.format(v);

/// Participación sobre el total; con un decimal cuando es menor a 10%.
String fmtPct(double v, double tot) {
  if (tot <= 0) return '0%';
  final p = v / tot * 100;
  return p < 10 ? '${(p * 10).round() / 10}%' : '${p.round()}%';
}

/// Una barra apilada: pedidos abajo, tickets arriba.
class BarraVenta {
  final String etiqueta;
  final double pedidos;
  final double tickets;

  const BarraVenta(this.etiqueta, this.pedidos, this.tickets);

  double get total => pedidos + tickets;
}

/// Tarjeta con título, leyenda (Pedidos / Tickets / Total) y la gráfica de
/// barras apiladas. Al tocar una barra se resalta y abajo se muestra su
/// desglose (en la web es el tooltip al pasar el mouse).
class VentasBarrasCard extends HookWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final List<BarraVenta> barras;

  /// Modo ranking (vendedores): nombres inclinados, % de participación y
  /// medallas al top 3.
  final bool ranking;

  /// Etiqueta del eje X (p. ej. la fecha corta).
  final String Function(BarraVenta)? etiquetaEje;

  /// Título del desglose al tocar una barra.
  final String Function(BarraVenta)? tituloDetalle;

  const VentasBarrasCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.barras,
    this.ranking = false,
    this.etiquetaEje,
    this.tituloDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final sel = useState<int?>(null);
    final totPed = barras.fold<double>(0, (a, b) => a + b.pedidos);
    final totTik = barras.fold<double>(0, (a, b) => a + b.tickets);
    final suma = totPed + totTik;
    final idx = sel.value;
    final elegido = (idx != null && idx < barras.length) ? barras[idx] : null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kColorBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 18, color: kColorPedidos),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kColorTexto,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              style: const TextStyle(fontSize: 12, color: kColorTextoTenue),
            ),
            const SizedBox(height: 12),
            VentasLeyenda(pedidos: totPed, tickets: totTik),
            const SizedBox(height: 12),
            if (barras.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Sin ventas registradas todavía.',
                    style: TextStyle(color: kColorTextoTenue),
                  ),
                ),
              )
            else
              // Celular en vertical: las columnas no caben, así que cada día o
              // vendedor va en su propia fila con la barra acostada.
              LayoutBuilder(
                builder: (context, c) => c.maxWidth < 560
                    ? _BarrasHorizontales(
                        barras: barras,
                        ranking: ranking,
                        seleccionado: idx,
                        etiqueta: etiquetaEje ?? (b) => b.etiqueta,
                        onTap: (i) => sel.value = sel.value == i ? null : i,
                      )
                    : _GraficaBarras(
                        barras: barras,
                        ranking: ranking,
                        seleccionado: idx,
                        etiquetaEje: etiquetaEje ?? (b) => b.etiqueta,
                        onTap: (i) => sel.value = sel.value == i ? null : i,
                      ),
              ),
            if (elegido != null) ...[
              const SizedBox(height: 10),
              _Detalle(
                titulo: tituloDetalle?.call(elegido) ?? elegido.etiqueta,
                barra: elegido,
                suma: ranking ? suma : 0,
              ),
            ] else ...[
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Toca una barra para ver el detalle.',
                  style: TextStyle(fontSize: 11, color: kColorTextoTenue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Leyenda estilo dashboard: cada serie con su total debajo y el total general.
class VentasLeyenda extends StatelessWidget {
  final double pedidos;
  final double tickets;

  const VentasLeyenda({super.key, required this.pedidos, required this.tickets});

  @override
  Widget build(BuildContext context) {
    Widget item(Color? color, String label, double valor, {bool total = false}) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (color != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style:
                      const TextStyle(fontSize: 12.5, color: kColorTextoTenue)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            fmtMoney.format(valor),
            style: TextStyle(
              fontSize: total ? 16 : 15,
              fontWeight: FontWeight.w600,
              color: kColorTexto,
            ),
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        item(kColorPedidos, 'Pedidos', pedidos),
        item(kColorTickets, 'Tickets', tickets),
        item(null, 'Total', pedidos + tickets, total: true),
      ],
    );
  }
}

class _Detalle extends StatelessWidget {
  final String titulo;
  final BarraVenta barra;
  final double suma;

  const _Detalle({required this.titulo, required this.barra, required this.suma});

  @override
  Widget build(BuildContext context) {
    Widget fila(Color? color, String label, String valor, {bool bold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            if (color != null) ...[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.5,
                      color: bold ? kColorTexto : kColorTextoTenue,
                      fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
            ),
            Text(valor,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                    color: kColorTexto)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kColorBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: kColorTexto)),
          const SizedBox(height: 6),
          fila(kColorPedidos, 'Pedidos', fmtMoney.format(barra.pedidos)),
          fila(kColorTickets, 'Tickets', fmtMoney.format(barra.tickets)),
          const Divider(height: 10, color: kColorBorde),
          fila(null, 'Total', fmtMoney.format(barra.total), bold: true),
          if (suma > 0)
            fila(null, 'Participación', fmtPct(barra.total, suma)),
        ],
      ),
    );
  }
}

/// Redondea hacia arriba a un valor "bonito" para el techo del eje Y.
double _niceCeil(double v) {
  final p = math.pow(10, (math.log(v <= 0 ? 1 : v) / math.ln10).floor()).toDouble();
  for (final m in [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10]) {
    if (m * p >= v) return m * p;
  }
  return 10 * p;
}

/// Versión para pantalla angosta: una fila por barra con etiqueta y total
/// arriba, y la barra apilada acostada (pedidos a la izquierda, tickets a la
/// derecha), proporcional a la barra más grande.
class _BarrasHorizontales extends StatelessWidget {
  final List<BarraVenta> barras;
  final bool ranking;
  final int? seleccionado;
  final String Function(BarraVenta) etiqueta;
  final ValueChanged<int> onTap;

  const _BarrasHorizontales({
    required this.barras,
    required this.ranking,
    required this.seleccionado,
    required this.etiqueta,
    required this.onTap,
  });

  static const _medallas = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final maximo =
        barras.fold<double>(0, (a, b) => math.max(a, b.total));
    final suma = barras.fold<double>(0, (a, b) => a + b.total);

    return Column(
      children: [
        for (var i = 0; i < barras.length; i++)
          _fila(i, barras[i], maximo, suma),
      ],
    );
  }

  Widget _fila(int i, BarraVenta b, double maximo, double suma) {
    final atenuar = seleccionado != null && seleccionado != i;
    final nombre = ranking && i < _medallas.length
        ? '${_medallas[i]} ${etiqueta(b)}'
        : ranking
            ? '${i + 1}.  ${etiqueta(b)}'
            : etiqueta(b);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Opacity(
        opacity: atenuar ? 0.3 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: seleccionado == i
                ? kColorPedidos.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: kColorTexto),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fmtMoney.format(b.total),
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: kColorTexto),
                  ),
                  if (ranking) ...[
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Text(
                        fmtPct(b.total, suma),
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: kColorTextoTenue),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              LayoutBuilder(builder: (context, c) {
                // Se descuentan los 2px de separación entre segmentos
                final escala = maximo > 0 ? (c.maxWidth - 2) / maximo : 0.0;
                final wP = b.pedidos * escala;
                final wT = b.tickets * escala;
                return Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      if (wP > 0) _segmento(wP, b.pedidos, kColorPedidos),
                      if (wP > 0 && wT > 0) const SizedBox(width: 2),
                      if (wT > 0) _segmento(wT, b.tickets, kColorTickets),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Segmento con su monto adentro si cabe
  Widget _segmento(double ancho, double valor, Color color) {
    return Container(
      width: math.max(ancho - 1, 2),
      color: color,
      alignment: Alignment.center,
      child: ancho >= 48
          ? Text(
              fmtK(valor),
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            )
          : null,
    );
  }
}

class _GraficaBarras extends StatelessWidget {
  final List<BarraVenta> barras;
  final bool ranking;
  final int? seleccionado;
  final String Function(BarraVenta) etiquetaEje;
  final ValueChanged<int> onTap;

  const _GraficaBarras({
    required this.barras,
    required this.ranking,
    required this.seleccionado,
    required this.etiquetaEje,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final g = _Geometria(barras.length, constraints.maxWidth, ranking);
      final lienzo = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          final i = ((d.localPosition.dx - g.padL) / g.grupo).floor();
          if (i >= 0 && i < barras.length) onTap(i);
        },
        child: CustomPaint(
          size: Size(g.ancho, g.alto),
          painter: _BarrasPainter(
            barras: barras,
            geo: g,
            ranking: ranking,
            seleccionado: seleccionado,
            etiquetaEje: etiquetaEje,
          ),
        ),
      );
      // Con muchas barras la gráfica se desplaza en horizontal, como en la web
      return g.ancho > constraints.maxWidth
          ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: lienzo)
          : Center(child: lienzo);
    });
  }
}

class _Geometria {
  final double padL = 52, padR = 8;
  late final double padT, padB, alto, grupo, bw, ancho;

  _Geometria(int n, double disponible, bool ranking) {
    padT = ranking ? 42 : 30;
    padB = ranking ? 96 : 30;
    alto = ranking ? 360 : 300;
    grupo = ((disponible - padL - padR) / n)
        .floorToDouble()
        .clamp(40.0, 110.0);
    bw = (grupo - 14).clamp(24.0, 56.0);
    ancho = padL + padR + n * grupo;
  }
}

class _BarrasPainter extends CustomPainter {
  final List<BarraVenta> barras;
  final _Geometria geo;
  final bool ranking;
  final int? seleccionado;
  final String Function(BarraVenta) etiquetaEje;

  _BarrasPainter({
    required this.barras,
    required this.geo,
    required this.ranking,
    required this.seleccionado,
    required this.etiquetaEje,
  });

  static const _medallas = ['🥇', '🥈', '🥉'];

  void _texto(Canvas c, String s, Offset p,
      {double size = 11,
      Color color = kColorTextoTenue,
      FontWeight weight = FontWeight.normal,
      TextAlign align = TextAlign.center,
      double rotar = 0}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    c.save();
    c.translate(p.dx, p.dy);
    if (rotar != 0) c.rotate(rotar);
    final dx = align == TextAlign.center
        ? -tp.width / 2
        : align == TextAlign.right
            ? -tp.width
            : 0.0;
    tp.paint(c, Offset(dx, -tp.height / 2));
    c.restore();
  }

  // Barra con esquinas redondeadas solo arriba (estilo dashboard)
  Path _barTop(double x, double y, double w, double h, [double r = 4]) {
    r = math.min(r, math.min(w / 2, h));
    return Path()
      ..moveTo(x, y + h)
      ..lineTo(x, y + r)
      ..quadraticBezierTo(x, y, x + r, y)
      ..lineTo(x + w - r, y)
      ..quadraticBezierTo(x + w, y, x + w, y + r)
      ..lineTo(x + w, y + h)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final g = geo;
    final techo = _niceCeil(
        barras.map((b) => b.total).fold<double>(1, (a, b) => math.max(a, b)));
    final altoUtil = g.alto - g.padT - g.padB;
    double y(double v) => g.padT + altoUtil * (1 - v / techo);
    double alto(double v) => altoUtil * v / techo;
    final suma = barras.fold<double>(0, (a, b) => a + b.total);

    // Cuadrícula punteada y etiquetas del eje Y
    final grid = Paint()
      ..color = kColorBorde
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final v = techo * i / 4;
      final yy = y(v);
      if (i == 0) {
        canvas.drawLine(Offset(g.padL, yy), Offset(g.ancho - g.padR, yy), grid);
      } else {
        for (double x = g.padL; x < g.ancho - g.padR; x += 6) {
          canvas.drawLine(Offset(x, yy),
              Offset(math.min(x + 3, g.ancho - g.padR), yy), grid);
        }
      }
      _texto(canvas, fmtK(v), Offset(g.padL - 6, yy),
          align: TextAlign.right, size: 10.5);
    }

    for (var i = 0; i < barras.length; i++) {
      final b = barras[i];
      final cx = g.padL + i * g.grupo + g.grupo / 2;
      final x0 = cx - g.bw / 2;
      final atenuar = seleccionado != null && seleccionado != i;
      final op = atenuar ? 0.3 : 1.0;
      final pPed = Paint()..color = kColorPedidos.withValues(alpha: op);
      final pTik = Paint()..color = kColorTickets.withValues(alpha: op);

      // Apilada: pedidos abajo (azul), tickets arriba (naranja) con 2px de
      // separación; solo el segmento superior lleva el tope redondeado
      if (b.pedidos > 0) {
        final hP = math.max(alto(b.pedidos), 2.0);
        if (b.tickets > 0) {
          canvas.drawRect(Rect.fromLTWH(x0, y(b.pedidos), g.bw, hP), pPed);
        } else {
          canvas.drawPath(_barTop(x0, y(b.pedidos), g.bw, hP), pPed);
        }
      }
      if (b.tickets > 0) {
        final hT = math.max(alto(b.tickets) - (b.pedidos > 0 ? 2 : 0), 2.0);
        canvas.drawPath(_barTop(x0, y(b.total), g.bw, hT), pTik);
      }
      _segTxt(canvas, cx, y(b.pedidos), alto(b.pedidos), b.pedidos, op);
      _segTxt(canvas, cx, y(b.total), alto(b.tickets), b.tickets, op);

      // Arriba de la barra: total (pedidos + tickets) y en ranking su %
      if (b.total > 0) {
        final colTot = kColorTexto.withValues(alpha: op);
        if (ranking) {
          _texto(canvas, fmtK(b.total), Offset(cx, y(b.total) - 22),
              weight: FontWeight.w600, color: colTot);
          _texto(canvas, fmtPct(b.total, suma), Offset(cx, y(b.total) - 9),
              size: 10.5,
              weight: FontWeight.w600,
              color: kColorTextoTenue.withValues(alpha: op));
        } else {
          _texto(canvas, fmtK(b.total), Offset(cx, y(b.total) - 9),
              weight: FontWeight.w600, color: colTot);
        }
      }

      // Etiqueta del eje X
      final eti = etiquetaEje(b);
      if (ranking) {
        final nombre = eti.length > 18 ? '${eti.substring(0, 17)}…' : eti;
        _texto(canvas, nombre, Offset(cx + 4, g.alto - g.padB + 12),
            size: 10.5, align: TextAlign.right, rotar: -32 * math.pi / 180);
        if (i < _medallas.length) {
          _texto(canvas, _medallas[i], Offset(cx, g.alto - 10), size: 14);
        }
      } else {
        _texto(canvas, eti, Offset(cx, g.alto - g.padB + 14), size: 10.5);
      }
    }
  }

  // Monto dentro de un segmento: horizontal si la barra es ancha y el
  // segmento alto; rotado si es angosto pero alto; nada si no cabe
  void _segTxt(Canvas c, double cx, double ySeg, double hSeg, double v, double op) {
    if (v <= 0) return;
    final color = Colors.white.withValues(alpha: op);
    if (hSeg >= 18 && geo.bw >= 44) {
      _texto(c, fmtK(v), Offset(cx, ySeg + hSeg / 2),
          size: 10, weight: FontWeight.w600, color: color);
    } else if (hSeg >= 44) {
      _texto(c, fmtK(v), Offset(cx, ySeg + hSeg / 2),
          size: 10,
          weight: FontWeight.w600,
          color: color,
          rotar: -math.pi / 2);
    }
  }

  @override
  bool shouldRepaint(covariant _BarrasPainter old) =>
      old.barras != barras ||
      old.seleccionado != seleccionado ||
      old.geo.ancho != geo.ancho;
}
