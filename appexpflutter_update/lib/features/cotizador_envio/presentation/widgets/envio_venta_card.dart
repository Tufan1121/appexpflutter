import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/envio_parcial.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/product_shipping_info.dart';
import 'package:appexpflutter_update/features/cotizador_envio/presentation/widgets/aviso_envio_quitado.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/shipping_quote_modal_v2.dart';

/// Partidas con las que se cotizó cada lista de envíos (clave:cantidad). Si
/// cambian (se agregó, quitó o cambió de cantidad un tapete) el envío ya no
/// corresponde y se quita.
final Expando<String> _firmaEnvios = Expando('firmaEnvios');

/// Botón "Cotizar envío" y, con envío elegido, su resumen con el importe y la
/// opción de quitarlo. Lo usan la cotización (ventas) y el punto de venta; cada
/// uno pasa sus propios [envios] (UtilsVenta.envios).
class EnvioVentaCard extends StatelessWidget {
  const EnvioVentaCard({
    super.key,
    required this.envios,
    required this.productos,
    required this.onChanged,
  });

  final EnviosCotizados envios;

  /// Partidas actuales con sus medidas de empaque y cantidades.
  final List<ProductShippingInfo> productos;

  /// Se agregó o quitó un envío: el padre recalcula su total.
  final VoidCallback onChanged;

  String get _firmaActual =>
      productos.map((p) => '${p.productKey}:${p.cantidad}').join(';');

  Map<String, String> get _partidas =>
      {for (final p in productos) p.productKey: p.productName};

  CoberturaEnvios _cobertura() {
    final cubiertas = envios.cubiertas;
    return CoberturaEnvios(
      envios: List.unmodifiable(envios.lista),
      faltan: {
        for (final p in _partidas.entries)
          if (!cubiertas.contains(p.key)) p.key: p.value,
      },
    );
  }

  void _abrirCotizador(BuildContext context) {
    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega productos primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    ShippingQuoteModalV2.show(
      context: context,
      products: productos,
      onShippingSelected: (envio) {
        envios.agregar(envio);
        _firmaEnvios[envios] = _firmaActual;
        onChanged();
      },
      cobertura: _cobertura,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!envios.isEmpty && _firmaEnvios[envios] != _firmaActual) {
      envios.clear();
      _firmaEnvios[envios] = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        mostrarAvisoEnvioQuitado(context,
            'Se quitó el envío cotizado porque cambiaron los productos o sus cantidades.');
        onChanged();
      });
    }

    if (envios.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: OutlinedButton.icon(
          onPressed: () => _abrirCotizador(context),
          icon: const Icon(Icons.local_shipping_rounded, size: 20),
          label: Text('Cotizar envío',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colores.secondaryColor,
            backgroundColor: Colors.white,
            side: BorderSide(color: Colores.secondaryColor.withOpacity(0.4)),
            minimumSize: const Size.fromHeight(40),
          ),
        ),
      );
    }

    final faltan = _cobertura().faltan.length;
    final estilo =
        GoogleFonts.montserrat(fontSize: 10, color: Colores.textSecondary);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // Fondo blanco: la lista va sobre el degradado oscuro de la pantalla.
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colores.secondaryColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_rounded,
              color: Colores.secondaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Envío ${envios.carriers}',
                    style: GoogleFonts.montserrat(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                // Una línea por envío (paquete, Big Ticket...), con los
                // tapetes que cubre si no son todos.
                for (final e in envios.lista)
                  Text(
                    envios.lista.length == 1
                        ? e.servicio
                        : '${e.carrier} ${Utils.formatPrice(e.importe)}'
                            '${e.parcial && e.cubre != null ? ' · ${e.cubre!.values.join(', ')}' : ''}',
                    style: estilo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (envios.ruta.isNotEmpty)
                  Text(envios.ruta,
                      style: estilo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                // Tapetes sin envío: se puede agregar otra paquetería.
                if (faltan > 0)
                  InkWell(
                    onTap: () => _abrirCotizador(context),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ Cotizar envío de lo que falta ($faltan)',
                        style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colores.secondaryColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            Utils.formatPrice(envios.total.roundToDouble()),
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colores.primaryColor),
          ),
          IconButton(
            tooltip: 'Quitar envío',
            icon: const Icon(Icons.close_rounded, size: 18),
            color: Colores.textSecondary,
            onPressed: () {
              envios.clear();
              _firmaEnvios[envios] = null;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
