import 'package:appexpflutter_update/config/miles_input_formatter.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/upper_case_text_formatter.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Servicios (p. ej. lavado de tapete) y anticipos del ticket, como en el punto
/// de venta de la galería: partidas sin mercancía (clave SERVICIO / ANTICIPO)
/// con descripción libre e importe. Se guardan en [UtilsVenta.servicios].
class ServiciosVentaCard extends StatefulWidget {
  const ServiciosVentaCard({super.key});

  @override
  State<ServiciosVentaCard> createState() => _ServiciosVentaCardState();
}

class _ServiciosVentaCardState extends State<ServiciosVentaCard> {
  /// Clave que se está capturando ('SERVICIO' o 'ANTICIPO'); null = cerrado.
  String? _capturando;
  final _desc = TextEditingController();
  final _precio = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _desc.dispose();
    _precio.dispose();
    super.dispose();
  }

  bool get _esAnticipo => _capturando == 'ANTICIPO';

  void _abrir(String clave) => setState(() {
        _capturando = clave;
        _error = null;
        _desc.clear();
        _precio.clear();
      });

  void _cerrar() => setState(() => _capturando = null);

  void _agregar() {
    final desc = _desc.text.trim();
    final precio = double.tryParse(_precio.text.replaceAll(',', '')) ?? 0;
    if (desc.isEmpty) {
      setState(() => _error = _esAnticipo
          ? 'Captura el concepto del anticipo.'
          : 'Captura la descripción del servicio.');
      return;
    }
    if (precio <= 0) {
      setState(() => _error = _esAnticipo
          ? 'Captura el importe del anticipo.'
          : 'Captura el precio del servicio.');
      return;
    }
    setState(() {
      UtilsVenta.servicios.add(ServicioVenta(
          clave: _capturando!, descripcion: desc.toUpperCase(), precio: precio));
      _capturando = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicios = UtilsVenta.servicios;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _abrir('SERVICIO'),
                      icon: const Icon(PhosphorIconsLight.sparkle),
                      label: const Text('SERVICIO'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _abrir('ANTICIPO'),
                      icon: const Icon(PhosphorIconsLight.piggyBank),
                      label: const Text('ANTICIPO'),
                    ),
                  ),
                ],
              ),
              if (_capturando != null) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  autofocus: true,
                  maxLength: 250,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseTextFormatter()],
                  decoration: InputDecoration(
                    labelText: _esAnticipo
                        ? 'Concepto del anticipo'
                        : 'Descripción del servicio',
                    hintText: _esAnticipo
                        ? 'Ej. ANTICIPO TAPETE PERSA 2.00 X 3.00 APROX'
                        : 'Ej. LAVADO DE TAPETE 2.00 X 3.00',
                    hintStyle: const TextStyle(color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _precio,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [MilesInputFormatter()],
                  onSubmitted: (_) => _agregar(),
                  decoration: InputDecoration(
                    labelText: _esAnticipo ? 'Importe' : 'Precio',
                    prefixText: '\$ ',
                    suffixText: 'MXN',
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _cerrar, child: const Text('CANCELAR')),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colores.secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      onPressed: _agregar,
                      icon: const Icon(PhosphorIconsLight.plus),
                      label: const Text('AGREGAR'),
                    ),
                  ],
                ),
              ],
              for (var i = 0; i < servicios.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                      servicios[i].esAnticipo
                          ? PhosphorIconsLight.piggyBank
                          : PhosphorIconsLight.sparkle,
                      color: Colores.secondaryColor),
                  title: Text(servicios[i].esAnticipo ? 'ANTICIPO' : 'SERVICIO',
                      style: const TextStyle(
                          fontSize: 12, letterSpacing: 1.2)),
                  subtitle: Text(servicios[i].descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Utils.formatPrice(servicios[i].precio),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        tooltip: 'Quitar',
                        icon: const Icon(PhosphorIconsLight.trash,
                            color: Colors.red),
                        onPressed: () =>
                            setState(() => UtilsVenta.servicios.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              if (servicios.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      'Servicios y anticipos: ${Utils.formatPrice(UtilsVenta.serviciosTotal)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
