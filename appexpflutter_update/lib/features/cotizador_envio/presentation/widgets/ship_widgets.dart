import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_quote.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/repositories/shipping_repository.dart';

/// Icono, color y nombre por paquetería (misma paleta que `CARRIER_COLORS`
/// en galería).
class CarrierStyle {
  CarrierStyle._();

  static IconData icon(String carrier) {
    switch (carrier) {
      case 'paquetexpress':
        return Icons.inventory_2_rounded;
      case 'fedex':
        return Icons.flight_rounded;
      case 'fedexFreight':
        return Icons.local_shipping_rounded;
      case 'dhl':
        return Icons.local_shipping_rounded;
      case 'tresguerras':
        return Icons.factory_rounded;
      case 'estafeta':
        return Icons.markunread_mailbox_rounded;
      case 'ups':
        return Icons.inventory_rounded;
      case 'sendex':
        return Icons.delivery_dining_rounded;
      case 'almex':
        return Icons.view_in_ar_rounded;
      case 'castores':
        return Icons.local_shipping_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  static Color color(String carrier) {
    switch (carrier) {
      case 'paquetexpress':
        return const Color(0xFF2563EB); // blue
      case 'fedex':
      case 'fedexFreight':
        return const Color(0xFF7C3AED); // purple
      case 'dhl':
        return const Color(0xFFCA8A04); // yellow (oscuro para que se lea)
      case 'tresguerras':
        return const Color(0xFFDC2626); // red
      case 'estafeta':
        return const Color(0xFFEA580C); // orange
      case 'ups':
        return const Color(0xFFB45309); // amber 700
      case 'sendex':
        return const Color(0xFF0D9488); // teal
      case 'almex':
        return const Color(0xFF4F46E5); // indigo
      case 'castores':
        return const Color(0xFFE11D48); // rose
      default:
        return Colores.primaryColor;
    }
  }

  static String name(String carrier) {
    switch (carrier) {
      case 'paquetexpress':
        return 'Paquetexpress';
      case 'fedex':
        return 'FedEx';
      case 'fedexFreight':
        return 'FedEx Freight';
      case 'dhl':
        return 'DHL';
      case 'tresguerras':
        return 'Tres Guerras';
      case 'estafeta':
        return 'Estafeta';
      case 'ups':
        return 'UPS';
      case 'sendex':
        return 'Sendex';
      case 'almex':
        return 'Almex';
      case 'castores':
        return 'Castores';
      default:
        return carrier;
    }
  }
}

/// Pastilla pequeña (Mejor precio, Ocurre, solo X de N productos...).
class ShipTag extends StatelessWidget {
  final String text;
  final Color color;

  const ShipTag({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Selectores de empaque para carga y tipo de entrega, con la nota de qué
/// paqueterías se consultan.
class ShipOptionsSelector extends StatelessWidget {
  final ShipEmpaque empaque;
  final ShipEntrega entrega;
  final ValueChanged<ShipEmpaque> onEmpaqueChanged;
  final ValueChanged<ShipEntrega> onEntregaChanged;
  final bool enabled;

  const ShipOptionsSelector({
    super.key,
    required this.empaque,
    required this.entrega,
    required this.onEmpaqueChanged,
    required this.onEntregaChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _dropdown<ShipEmpaque>(
                label: 'Empaque para carga',
                icon: Icons.inventory_2_outlined,
                value: empaque,
                items: ShipEmpaque.values,
                labelOf: (e) => e.label,
                onChanged: enabled ? onEmpaqueChanged : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dropdown<ShipEntrega>(
                label: 'Entrega',
                icon: Icons.storefront_outlined,
                value: entrega,
                items: ShipEntrega.values,
                labelOf: (e) => e == ShipEntrega.ocurre ? 'En ocurre (recoge en sucursal)' : 'A domicilio',
                onChanged: enabled ? onEntregaChanged : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Se cotiza como paquete (Paquetexpress, FedEx, DHL, Estafeta, UPS, Sendex) '
          'y como carga (Almex, Tres Guerras Big Ticket, Paquetexpress LTL, FedEx Freight, '
          'Estafeta, Castores). Ocurre lo ofrecen Paquetexpress, Almex, Estafeta y Tres Guerras.',
          style: GoogleFonts.inter(fontSize: 10, color: Colores.textTertiary, height: 1.3),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T>? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      isDense: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colores.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colores.textSecondary, fontSize: 11),
        prefixIcon: Icon(icon, color: Colores.primaryColor, size: 18),
        filled: true,
        fillColor: Colors.grey[50],
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colores.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(labelOf(e), overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged == null ? null : (v) => v == null ? null : onChanged(v),
    );
  }
}

/// Bloque plegable "Paquetería normal (paquete)" / "Carga / Big Ticket".
class ShipSection extends StatelessWidget {
  final String titulo;
  final IconData icono;

  /// "3 opciones", "2 paqueterías" o el texto de vacío.
  final String resumen;

  /// Nota adicional, p. ej. "para bultos que no entran como paquete".
  final String nota;
  final bool abierta;
  final VoidCallback onToggle;
  final List<Widget> children;

  /// Color del texto del encabezado (blanco sobre fondo degradado).
  final Color? colorTexto;

  const ShipSection({
    super.key,
    required this.titulo,
    required this.icono,
    required this.resumen,
    this.nota = '',
    required this.abierta,
    required this.onToggle,
    required this.children,
    this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorTexto ?? Colores.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(icono, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 12, color: color),
                      children: [
                        TextSpan(
                          text: titulo.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: color,
                          ),
                        ),
                        TextSpan(
                          text: '  $resumen${nota.isNotEmpty ? ' · $nota' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: color.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: abierta ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.expand_more_rounded, size: 20, color: color),
                ),
              ],
            ),
          ),
        ),
        if (abierta) ...children,
      ],
    );
  }
}

/// Card de una tarifa. Si `cantidad` > 1 se muestra precio × cantidad = total.
/// Con `onTap` la card es seleccionable.
class ShipRateTile extends StatefulWidget {
  final ShippingOption option;
  final int cantidad;
  final bool mejorPrecio;
  final VoidCallback? onTap;

  /// Selector de sucursal (ocurre) que sustituye a la lista plegable de
  /// sucursales cuando la tarifa se puede elegir.
  final Widget? branchSelector;

  const ShipRateTile({
    super.key,
    required this.option,
    this.cantidad = 1,
    this.mejorPrecio = false,
    this.onTap,
    this.branchSelector,
  });

  @override
  State<ShipRateTile> createState() => _ShipRateTileState();
}

class _ShipRateTileState extends State<ShipRateTile> {
  bool _verSucursales = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.option;
    final color = CarrierStyle.color(o.carrier);
    final tiempo = o.tiempoEntrega;
    final total = o.price * widget.cantidad;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(CarrierStyle.icon(o.carrier), color: color, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                o.carrierDescription.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                              if (widget.mejorPrecio)
                                const ShipTag(text: 'Mejor precio', color: Colores.successColor),
                              if (o.esOcurre)
                                const ShipTag(text: 'Ocurre', color: Colores.warningColor),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${o.serviceDescription}${o.esOcurre ? ' · ${o.entregaDesc}' : ''}',
                            style: GoogleFonts.inter(fontSize: 11, color: Colores.textSecondary),
                          ),
                          Text(
                            '${o.modo.label} · ${ShippingRepository.labelEmpaque(o.empaque)}'
                            '${tiempo.isNotEmpty ? ' · $tiempo' : ''}',
                            style: GoogleFonts.inter(fontSize: 10, color: Colores.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Utils.formatPrice(total),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colores.textPrimary,
                          ),
                        ),
                        Text(
                          widget.cantidad > 1
                              ? '${Utils.formatPrice(o.price)} × ${widget.cantidad}'
                              : o.currency,
                          style: GoogleFonts.inter(fontSize: 9, color: Colores.textTertiary),
                        ),
                      ],
                    ),
                    if (widget.onTap != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, color: Colores.textTertiary, size: 20),
                    ],
                  ],
                ),
                if (o.esOcurre) ...[
                  const SizedBox(height: 6),
                  if (o.branches.isEmpty)
                    Text(
                      'Sin lista de sucursales; confirmar el ocurre con la paquetería.',
                      style: GoogleFonts.inter(fontSize: 10, color: Colores.warningColor),
                    )
                  else if (widget.branchSelector != null)
                    widget.branchSelector!
                  else ...[
                    InkWell(
                      onTap: () => setState(() => _verSucursales = !_verSucursales),
                      child: Text(
                        'Sucursal más cercana: ${o.branches.first.nombre}'
                        '${o.branches.first.km != null ? ' (${o.branches.first.km} km)' : ''}'
                        ' · ${_verSucursales ? 'ocultar' : 'ver'} ${o.branches.length} sucursal${o.branches.length != 1 ? 'es' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colores.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_verSucursales) ShipBranchList(branches: o.branches),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lista de sucursales (ocurre) con borde izquierdo.
class ShipBranchList extends StatelessWidget {
  final List<ShippingBranch> branches;

  const ShipBranchList({super.key, required this.branches});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: branches
            .map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 10, color: Colores.textSecondary),
                      children: [
                        TextSpan(
                          text: b.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (b.km != null) TextSpan(text: ' (${b.km} km)'),
                        if (b.dir.isNotEmpty) TextSpan(text: ' · ${b.dir}'),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// "N paqueterías rechazaron este bulto (ver motivos)" plegable.
class ShipRechazosList extends StatefulWidget {
  final List<ShipRejection> rechazos;
  final bool abiertoInicial;

  /// "paquete", "producto", "bulto"...
  final String sujeto;

  const ShipRechazosList({
    super.key,
    required this.rechazos,
    this.abiertoInicial = false,
    this.sujeto = 'bulto',
  });

  @override
  State<ShipRechazosList> createState() => _ShipRechazosListState();
}

class _ShipRechazosListState extends State<ShipRechazosList> {
  late bool _abierto = widget.abiertoInicial;

  @override
  Widget build(BuildContext context) {
    if (widget.rechazos.isEmpty) return const SizedBox.shrink();
    final n = widget.rechazos.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _abierto = !_abierto),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _abierto ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 16,
                  color: Colores.textTertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '$n paqueter${n != 1 ? 'ías rechazaron' : 'ía rechazó'} este ${widget.sujeto} (ver motivos)',
                    style: GoogleFonts.inter(fontSize: 10, color: Colores.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_abierto)
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey[300]!, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.rechazos
                  .map((x) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(fontSize: 10, color: Colores.textSecondary),
                            children: [
                              TextSpan(
                                text: CarrierStyle.name(x.carrier),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: CarrierStyle.color(x.carrier),
                                ),
                              ),
                              TextSpan(
                                text: ' (${x.modo.label} · ${x.empaque}): ',
                                style: const TextStyle(color: Colores.textTertiary),
                              ),
                              TextSpan(text: x.motivo),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
