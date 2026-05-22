/// Algoritmo "¿quiso decir?" para sugerir calidades parecidas a lo que tipeó
/// el usuario cuando la búsqueda devuelve 0 resultados.
///
/// Réplica del lado JS del web
/// (`F:\python\galeria\busquedaglobal.html:1438-1496`): distancia de
/// Levenshtein más un score con bonus por prefijo / contiene / primera letra.
class SugerenciasCalidad {
  /// Devuelve hasta [max] calidades de [calidades] que se parecen a [input].
  /// Devuelve `[]` si [input] coincide exactamente con alguna candidata o si
  /// no hay parecidos suficientes.
  static List<String> sugerir(String input, List<String> calidades,
      {int max = 10}) {
    final q = input.trim().toUpperCase();
    if (q.isEmpty || calidades.isEmpty) return const [];

    final scored = <_Scored>[];
    for (final raw in calidades) {
      final c = raw.trim().toUpperCase();
      if (c.isEmpty) continue;
      if (c == q) return const []; // exacta: no hay nada que sugerir
      final d = _levenshtein(q, c);
      final maxLen = q.length > c.length ? q.length : c.length;
      double score = 1 - d / maxLen; // similitud 0..1
      if (c.startsWith(q)) {
        score += 0.35;
      } else if (c.contains(q)) {
        score += 0.20;
      } else if (q.contains(c)) {
        score += 0.10;
      }
      if (q[0] == c[0]) score += 0.05;
      scored.add(_Scored(c, score, d));
    }

    final umbralDist = q.length * 0.65;
    final umbral = umbralDist > 3 ? umbralDist.ceil() : 3;
    scored.removeWhere((s) => s.score < 0.35 && s.d > umbral);
    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.d.compareTo(b.d);
    });
    return scored.take(max).map((s) => s.c).toList();
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final m = a.length, n = b.length;
    var prev = List<int>.generate(n + 1, (j) => j);
    var curr = List<int>.filled(n + 1, 0);
    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        final del = curr[j - 1] + 1;
        final ins = prev[j] + 1;
        final sub = prev[j - 1] + cost;
        var min = del < ins ? del : ins;
        if (sub < min) min = sub;
        curr[j] = min;
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[n];
  }
}

class _Scored {
  final String c;
  final double score;
  final int d;
  _Scored(this.c, this.score, this.d);
}
