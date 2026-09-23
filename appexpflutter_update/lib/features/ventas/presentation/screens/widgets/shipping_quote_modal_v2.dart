import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/envio_parcial.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/product_shipping_info.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_quote.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/zipcode_info.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/repositories/shipping_repository.dart';
import 'package:appexpflutter_update/features/cotizador_envio/presentation/widgets/ship_widgets.dart';

/// Envío elegido (una partida ENVIO): importe, paquetería, servicio (modo,
/// guías y sucursal de ocurre), ruta "Origen: CP Ciudad -> Destino: CP
/// Ciudad" y los tapetes que cubre.
typedef ShippingSelectedCallback = void Function(EnvioAgregado envio);

/// Modal para cotizar el envío de uno o varios productos (sesión de ventas,
/// punto de venta y consultas de inventario / precios).
///
/// Cada producto se cotiza por separado como PAQUETE y como CARGA con todas
/// las paqueterías (misma lógica que `cotizaciones.html` en galería): el
/// resumen suma el mejor precio de cada producto × número de guías por
/// paquetería y modo; una paquetería que no cotizó todos los productos se
/// marca y va después de las completas. Se pueden agregar varias partidas
/// ENVIO (p. ej. paquete para el tapete chico y Big Ticket para el grande),
/// cada una con los tapetes que esa paquetería cotizó; mientras falten
/// tapetes por cubrir el modal sigue abierto con el aviso de cobertura. En
/// ocurre, el vendedor elige la sucursal donde recogerá el cliente y esa
/// queda en la observación de la partida ENVIO.
class ShippingQuoteModalV2 extends StatefulWidget {
  const ShippingQuoteModalV2({
    super.key,
    required this.products,
    required this.onShippingSelected,
    this.cobertura,
    this.consulta = false,
  });

  /// Envíos ya agregados y tapetes que faltan por cubrir (se lee después de
  /// cada "Agregar"); sin él, el modal se cierra al agregar.
  final CoberturaEnvios Function()? cobertura;

  /// Lista de productos con sus dimensiones y cantidades
  final List<ProductShippingInfo> products;

  /// Modo consulta (inventario / precios): solo se muestran las tarifas, sin
  /// botón de agregar envío.
  final bool consulta;

  /// Últimos códigos postales cotizados. Se conservan mientras la app esté
  /// abierta y son comunes a consultas, sesión de ventas y punto de venta:
  /// al volver a abrir el modal ya vienen puestos.
  static String _ultimoCpOrigen = '';
  static String _ultimoCpDestino = '';

  /// Callback cuando se selecciona un envío.
  final ShippingSelectedCallback onShippingSelected;

  /// Muestra el modal de cotización de envíos
  static Future<void> show({
    required BuildContext context,
    required List<ProductShippingInfo> products,
    required ShippingSelectedCallback onShippingSelected,
    CoberturaEnvios Function()? cobertura,
    bool consulta = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShippingQuoteModalV2(
        products: products,
        onShippingSelected: onShippingSelected,
        cobertura: cobertura,
        consulta: consulta,
      ),
    );
  }

  @override
  State<ShippingQuoteModalV2> createState() => _ShippingQuoteModalV2State();
}

class _ShippingQuoteModalV2State extends State<ShippingQuoteModalV2> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para códigos postales
  final _codigoPostalOrigenController = TextEditingController();
  final _codigoPostalDestinoController = TextEditingController();

  // Controladores para dimensiones de cada producto
  late List<TextEditingController> _largoControllers;
  late List<TextEditingController> _altoControllers;
  late List<TextEditingController> _anchoControllers;
  late List<TextEditingController> _pesoControllers;

  // Información de ubicación obtenida automáticamente
  ZipcodeInfo? _originInfo;
  ZipcodeInfo? _destinationInfo;
  String? _selectedOriginSuburb;
  String? _selectedDestinationSuburb;
  bool _isLoadingOrigin = false;
  bool _isLoadingDestination = false;

  final ShippingRepository _shippingRepository = ShippingRepository();

  ShipEmpaque _empaque = ShipEmpaque.roll;
  ShipEntrega _entrega = ShipEntrega.domicilio;

  bool _isLoading = false;
  String _progreso = '';
  String? _errorMessage;

  /// Resultado por producto (en el orden de `_uniqueProducts`).
  List<_ProductQuote>? _productResults;

  /// Totales por paquetería y modo, ya ordenados (completos primero, luego
  /// por precio).
  List<_CarrierTotal> _totPaquete = [];
  List<_CarrierTotal> _totCarga = [];
  bool _paqueteAbierto = true;
  bool _cargaAbierta = true;

  /// Sucursal elegida por total (clave carrier|modo) cuando es ocurre.
  final Map<String, int> _branchSel = {};

  /// Aviso de cobertura (envíos agregados y tapetes que faltan).
  final _coberturaKey = GlobalKey();

  /// Productos que entran en los totales (todos, o solo los que faltan por
  /// cubrir cuando ya hay envíos agregados).
  int _nTotales = 0;

  /// Claves que faltan por cubrir cuando ya hay envíos agregados; null =
  /// cotizar todo (sin envíos, o ya están todos cubiertos: se reemplazan).
  Set<String>? _clavesFaltantes() {
    final c = widget.consulta ? null : widget.cobertura?.call();
    if (c == null || c.envios.isEmpty || c.faltan.isEmpty) return null;
    return c.faltan.keys.toSet();
  }

  /// Productos únicos (agrupados por clave)
  late List<ProductShippingInfo> _uniqueProducts;

  /// Total de items en el pedido
  int get _totalItems => _uniqueProducts.fold(0, (sum, p) => sum + p.cantidad);

  @override
  void initState() {
    super.initState();
    _groupProducts();
    _initControllers();
    _restaurarCodigosPostales();
  }

  /// Vuelve a poner los CP de la cotización anterior y dispara la búsqueda
  /// de ciudad/estado para poder cotizar de inmediato.
  void _restaurarCodigosPostales() {
    if (ShippingQuoteModalV2._ultimoCpOrigen.length == 5) {
      _codigoPostalOrigenController.text = ShippingQuoteModalV2._ultimoCpOrigen;
      WidgetsBinding.instance.addPostFrameCallback((_) => _buscarInfoOrigen());
    }
    if (ShippingQuoteModalV2._ultimoCpDestino.length == 5) {
      _codigoPostalDestinoController.text = ShippingQuoteModalV2._ultimoCpDestino;
      WidgetsBinding.instance.addPostFrameCallback((_) => _buscarInfoDestino());
    }
  }

  void _recordarCodigosPostales() {
    ShippingQuoteModalV2._ultimoCpOrigen = _codigoPostalOrigenController.text.trim();
    ShippingQuoteModalV2._ultimoCpDestino = _codigoPostalDestinoController.text.trim();
  }

  /// Agrupa productos por clave, sumando cantidades si son iguales
  void _groupProducts() {
    final Map<String, ProductShippingInfo> grouped = {};

    for (final product in widget.products) {
      if (grouped.containsKey(product.productKey)) {
        final existing = grouped[product.productKey]!;
        grouped[product.productKey] = existing.copyWith(
          cantidad: existing.cantidad + product.cantidad,
        );
      } else {
        grouped[product.productKey] = product;
      }
    }

    _uniqueProducts = grouped.values.toList();
  }

  /// Inicializa los controladores con los valores de cada producto. Una
  /// medida en 0 (el catálogo no la tiene) queda vacía para capturarla.
  void _initControllers() {
    String cm(double v) => v > 0 ? v.toStringAsFixed(0) : '';
    _largoControllers = _uniqueProducts
        .map((p) => TextEditingController(text: cm(p.largo)))
        .toList();
    _altoControllers = _uniqueProducts
        .map((p) => TextEditingController(text: cm(p.alto)))
        .toList();
    _anchoControllers = _uniqueProducts
        .map((p) => TextEditingController(text: cm(p.ancho)))
        .toList();
    _pesoControllers = _uniqueProducts
        .map((p) => TextEditingController(text: p.peso > 0 ? p.peso.toString() : ''))
        .toList();
  }

  @override
  void dispose() {
    _codigoPostalOrigenController.dispose();
    _codigoPostalDestinoController.dispose();
    for (final c in _largoControllers) {
      c.dispose();
    }
    for (final c in _altoControllers) {
      c.dispose();
    }
    for (final c in _anchoControllers) {
      c.dispose();
    }
    for (final c in _pesoControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Obtiene los productos con las dimensiones actualizadas desde los controladores
  List<ProductShippingInfo> _getUpdatedProducts() {
    return List.generate(_uniqueProducts.length, (i) {
      final original = _uniqueProducts[i];
      return ProductShippingInfo(
        productKey: original.productKey,
        productName: original.productName,
        // Campo vacío = sin esa medida (el producto no se cotiza).
        largo: double.tryParse(_largoControllers[i].text) ?? 0,
        alto: double.tryParse(_altoControllers[i].text) ?? 0,
        ancho: double.tryParse(_anchoControllers[i].text) ?? 0,
        peso: double.tryParse(_pesoControllers[i].text) ?? 0,
        cantidad: original.cantidad,
      );
    });
  }

  /// Busca automáticamente la información del código postal de origen
  Future<void> _buscarInfoOrigen() async {
    final cp = _codigoPostalOrigenController.text.trim();
    if (cp.length != 5) {
      setState(() => _originInfo = null);
      return;
    }

    setState(() => _isLoadingOrigin = true);
    try {
      final info = await _shippingRepository.getZipcodeInfo(cp);
      if (!mounted) return;
      setState(() {
        _originInfo = info;
        _selectedOriginSuburb = info?.suburbs.isNotEmpty == true ? info!.suburbs.first : null;
        _isLoadingOrigin = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _originInfo = null;
        _isLoadingOrigin = false;
      });
    }
  }

  /// Busca automáticamente la información del código postal de destino
  Future<void> _buscarInfoDestino() async {
    final cp = _codigoPostalDestinoController.text.trim();
    if (cp.length != 5) {
      setState(() => _destinationInfo = null);
      return;
    }

    setState(() => _isLoadingDestination = true);
    try {
      final info = await _shippingRepository.getZipcodeInfo(cp);
      if (!mounted) return;
      setState(() {
        _destinationInfo = info;
        _selectedDestinationSuburb = info?.suburbs.isNotEmpty == true ? info!.suburbs.first : null;
        _isLoadingDestination = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _destinationInfo = null;
        _isLoadingDestination = false;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Cotiza cada producto por separado (cantidad = número de guías) con
  /// todas las paqueterías, en paquete y en carga.
  Future<void> _calcularCotizacion() async {
    FocusScope.of(context).unfocus(); // Cerrar teclado
    if (!_formKey.currentState!.validate()) return;

    if (_codigoPostalOrigenController.text.trim().length != 5 ||
        _codigoPostalDestinoController.text.trim().length != 5) {
      _snack('Los códigos postales deben tener 5 dígitos');
      return;
    }
    if (_originInfo == null || _destinationInfo == null) {
      _snack('Espera a que se cargue la información de los códigos postales');
      return;
    }
    if (_selectedOriginSuburb == null || _selectedDestinationSuburb == null) {
      _snack('No se pudo obtener información de los códigos postales');
      return;
    }

    _recordarCodigosPostales();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _productResults = null;
      _totPaquete = [];
      _totCarga = [];
      _branchSel.clear();
      _progreso = '';
    });

    final route = ShipRoute(
      originPostalCode: _codigoPostalOrigenController.text.trim(),
      originCity: _originInfo!.locality,
      originState: _originInfo!.stateCode2,
      originDistrict: _selectedOriginSuburb!,
      destinationPostalCode: _codigoPostalDestinoController.text.trim(),
      destinationCity: _destinationInfo!.locality,
      destinationState: _destinationInfo!.stateCode2,
      destinationDistrict: _selectedDestinationSuburb!,
    );

    try {
      final products = _getUpdatedProducts();
      final results = <_ProductQuote>[];

      for (var i = 0; i < products.length; i++) {
        final p = products[i];
        if (mounted) {
          setState(() => _progreso = products.length > 1
              ? 'Cotizando producto ${i + 1} de ${products.length}: ${p.productName}'
              : 'Consultando paqueterías (paquete y carga)...');
        }
        if (p.largo <= 0 || p.ancho <= 0 || p.alto <= 0 || p.peso <= 0) {
          results.add(_ProductQuote(
            product: p,
            error: 'Faltan dimensiones: captura largo, ancho, alto y peso',
          ));
          continue;
        }
        final r = await _shippingRepository.quote(
          route: route,
          largo: p.largo,
          ancho: p.ancho,
          alto: p.alto,
          peso: p.peso,
          empaque: _empaque,
          entrega: _entrega,
        );
        results.add(_ProductQuote(product: p, result: r));
      }

      _calcularTotales(results);

      if (!mounted) return;
      setState(() {
        _productResults = results;
        _isLoading = false;
        _progreso = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al obtener cotizaciones: ${e.toString()}';
        _isLoading = false;
        _progreso = '';
      });
    }
  }

  /// Totales por paquetería y modo (paquete / carga): suma del mejor precio
  /// de cada producto × cantidad. Paquete y carga se presentan en bloques
  /// separados, cada uno con su propio mejor precio; así Almex o Big Ticket
  /// no se mezclan con las paqueterías normales.
  ///
  /// Si ya hay envíos agregados y faltan tapetes, los totales se calculan
  /// solo con los que faltan: así una paquetería de carga que cotizó todo
  /// (p. ej. Almex) se agrega solo por el tapete grande y se suma al envío de
  /// paquete del chico, en vez de reemplazarlo.
  void _calcularTotales(List<_ProductQuote> todos) {
    final faltan = _clavesFaltantes();
    final results = faltan == null
        ? todos
        : todos.where((pr) => faltan.contains(pr.product.productKey)).toList();
    _nTotales = results.length;
    final totals = <String, _CarrierTotal>{};
    for (final pr in results) {
      final res = pr.result;
      if (res == null) continue;
      final bestByKey = <String, ShippingOption>{};
      for (final o in res.options) {
        final k = '${o.carrier}|${o.modo.name}';
        final prev = bestByKey[k];
        if (prev == null || o.price < prev.price) bestByKey[k] = o;
      }
      bestByKey.forEach((k, o) {
        final t = totals.putIfAbsent(
          k,
          () => _CarrierTotal(
            key: k,
            carrier: o.carrier,
            carrierDescription: o.carrierDescription,
            modo: o.modo,
          ),
        );
        final cost = o.price * pr.product.cantidad;
        t.total += cost;
        t.guides += pr.product.cantidad;
        t.productos += 1;
        t.breakdown.add(_Breakdown(product: pr.product, option: o, cost: cost));
        // Las sucursales dependen del CP destino, no del producto: con la
        // primera lista basta.
        if (t.branches.isEmpty && o.branches.isNotEmpty) t.branches = o.branches;
      });
    }

    // Una paquetería que no cotizó TODOS los productos se marca y va después
    // de las completas; si se elige, cubre solo los que cotizó.
    final nProductos = results.length;
    for (final t in totals.values) {
      t.completo = t.productos == nProductos;
      t.ocurre = _entrega == ShipEntrega.ocurre;
    }
    int ordenar(_CarrierTotal a, _CarrierTotal b) {
      if (a.completo != b.completo) return a.completo ? -1 : 1;
      return a.total.compareTo(b.total);
    }

    _totPaquete = totals.values.where((t) => t.modo == ShipModo.paquete).toList()..sort(ordenar);
    _totCarga = totals.values.where((t) => t.modo == ShipModo.carga).toList()..sort(ordenar);
  }

  /// Texto de la ruta cotizada con CP y ciudad de origen y destino, ej.
  /// "Origen: 45010 Zapopan, JAL -> Destino: 06600 Ciudad de México, CMX".
  /// Solo ASCII/latin-1 en los separadores: los PDF de fpdf y las impresoras
  /// de tickets no soportan flechas Unicode.
  String _rutaEnvio() {
    String lado(String cp, ZipcodeInfo? info) {
      final partes = <String>[cp];
      if (info != null) {
        final ciudad = info.locality.trim();
        final edo = info.stateCode2.trim();
        if (ciudad.isNotEmpty) {
          partes.add(edo.isNotEmpty ? '$ciudad, $edo' : ciudad);
        }
      }
      return partes.join(' ');
    }

    final origen = lado(_codigoPostalOrigenController.text.trim(), _originInfo);
    final destino = lado(_codigoPostalDestinoController.text.trim(), _destinationInfo);
    return 'Origen: $origen -> Destino: $destino';
  }

  /// Texto de ocurre para la observación de la partida ENVIO: paquetería y
  /// sucursal elegida (o "por confirmar" si no regresó lista).
  String _textoOcurre(ShippingBranch? b) {
    if (b == null) return 'Ocurre (sucursal por confirmar)';
    final buf = StringBuffer('Ocurre: ${b.nombre}');
    if (b.dir.isNotEmpty) buf.write(', ${b.dir}');
    if (b.km != null) buf.write(' (${b.km} km)');
    return buf.toString();
  }

  String _guias(int n) => '$n guía${n != 1 ? 's' : ''}';

  /// Nombre corto de un tapete para la cobertura: "Nombre (2)" si son varias
  /// piezas.
  String _nombreTapete(ProductShippingInfo p) =>
      p.cantidad > 1 ? '${p.productName.trim()} (${p.cantidad})' : p.productName.trim();

  /// Selección desde el resumen (mejor precio por paquetería y modo). Una
  /// paquetería incompleta también se puede elegir: el envío cubre solo los
  /// tapetes que cotizó y se puede agregar otra para el resto.
  void _seleccionarTotal(_CarrierTotal t) {
    final partes = <String>[
      '${t.carrierDescription} - ${t.modo.label}',
      _guias(t.guides),
    ];
    if (t.ocurre) {
      final sel = _branchSel[t.key] ?? 0;
      final b = sel < t.branches.length ? t.branches[sel] : null;
      partes.add(_textoOcurre(b));
    }
    _agregar(EnvioAgregado(
      importe: t.total,
      carrier: t.carrierDescription,
      servicio: partes.join(' · '),
      ruta: _rutaEnvio(),
      cubre: {
        for (final b in t.breakdown) b.product.productKey: _nombreTapete(b.product),
      },
      parcial: t.breakdown.length < _uniqueProducts.length,
    ));
  }

  /// Entrega el envío a la lista. Si todavía faltan tapetes por cubrir, el
  /// modal sigue abierto con el aviso de cobertura para agregar otra
  /// paquetería (p. ej. Big Ticket para el tapete grande).
  void _agregar(EnvioAgregado envio) {
    widget.onShippingSelected(envio);
    final cobertura = widget.cobertura?.call();
    if (cobertura == null || cobertura.faltan.isEmpty) {
      Navigator.pop(context);
      return;
    }
    // Las tarjetas pasan a cotizar solo lo que falta.
    setState(() {
      if (_productResults != null) _calcularTotales(_productResults!);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _coberturaKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  /// Clave para recordar la sucursal elegida de una tarifa concreta.
  String _keyOpcion(ShippingOption o) => '${o.carrier}|${o.modo.name}|${o.serviceId}';

  /// Selección de un servicio concreto (solo cuando hay un único producto:
  /// el total es precio × guías).
  void _seleccionarOpcion(ProductShippingInfo p, ShippingOption o) {
    final partes = <String>[
      '${o.carrierDescription} - ${o.serviceDescription} · ${o.modo.label}',
      _guias(p.cantidad),
    ];
    if (o.esOcurre) {
      final sel = _branchSel[_keyOpcion(o)] ?? 0;
      partes.add(_textoOcurre(sel < o.branches.length ? o.branches[sel] : null));
    }
    _agregar(EnvioAgregado(
      importe: o.price * p.cantidad,
      carrier: o.carrierDescription,
      servicio: partes.join(' · '),
      ruta: _rutaEnvio(),
      cubre: {p.productKey: _nombreTapete(p)},
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: mediaQuery.size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colores.gradientStart,
                          Colores.gradientMiddle,
                          Colores.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colores.primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cotizar Envío',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colores.textPrimary,
                          ),
                        ),
                        Text(
                          '${_uniqueProducts.length} tipo(s) de producto · $_totalItems unidad(es)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colores.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colores.textSecondary,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + mediaQuery.viewInsets.bottom),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Códigos Postales', Icons.pin_drop_rounded),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildZipcodeField(
                              controller: _codigoPostalOrigenController,
                              label: 'CP Origen',
                              icon: Icons.flight_takeoff_rounded,
                              info: _originInfo,
                              isLoading: _isLoadingOrigin,
                              onChanged: (_) => _buscarInfoOrigen(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildZipcodeField(
                              controller: _codigoPostalDestinoController,
                              label: 'CP Destino',
                              icon: Icons.flight_land_rounded,
                              info: _destinationInfo,
                              isLoading: _isLoadingDestination,
                              onChanged: (_) => _buscarInfoDestino(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('Dimensiones y Peso por Producto', Icons.straighten_rounded),
                      const SizedBox(height: 12),
                      ..._buildProductDimensionCards(),
                      const SizedBox(height: 8),

                      // Empaque para carga y tipo de entrega
                      _buildSectionTitle('Empaque y entrega', Icons.local_shipping_outlined),
                      const SizedBox(height: 12),
                      ShipOptionsSelector(
                        empaque: _empaque,
                        entrega: _entrega,
                        enabled: !_isLoading,
                        onEmpaqueChanged: (v) => setState(() => _empaque = v),
                        onEntregaChanged: (v) => setState(() => _entrega = v),
                      ),
                      const SizedBox(height: 20),

                      // Botón cotizar
                      _buildGradientButton(
                        label: _isLoading ? 'Cotizando...' : 'Cotizar Envío',
                        icon: _isLoading ? Icons.hourglass_top_rounded : Icons.calculate_rounded,
                        onPressed: _isLoading ? () {} : _calcularCotizacion,
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Loading
                      if (_isLoading) ...[
                        const SizedBox(height: 24),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                        Text(
                          _progreso.isNotEmpty
                              ? _progreso
                              : 'Consultando paqueterías (paquete y carga)...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: Colores.textSecondary),
                        ),
                      ],

                      // Resultados
                      if (_productResults != null && !_isLoading) ...[
                        const SizedBox(height: 24),
                        ..._buildResultados(),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Resultados
  // ---------------------------------------------------------------------------

  List<Widget> _buildResultados() {
    final results = _productResults!;
    final nProductos = results.length;
    final sinNada = results.every((pr) => (pr.result?.options.isEmpty ?? true));

    if (sinNada) {
      return [
        Column(
          children: [
            const Icon(Icons.sentiment_dissatisfied_rounded, size: 36, color: Colores.textTertiary),
            const SizedBox(height: 6),
            Text(
              'Ninguna paquetería aceptó estos productos en esta ruta. Motivos:',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: Colores.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...results.map((pr) => _buildProductoCard(pr, nProductos)),
      ];
    }

    // Envíos ya agregados y lo que falta (p. ej. se cotiza otra vez para
    // cubrir con Big Ticket el tapete que no entró como paquete).
    final cobertura = widget.consulta ? null : widget.cobertura?.call();

    final encabezado = <Widget>[
      if (cobertura != null && cobertura.envios.isNotEmpty) ...[
        _buildCobertura(cobertura),
        const SizedBox(height: 12),
      ],
      _buildSectionTitle(
        widget.consulta ? 'Cotizaciones disponibles' : 'Selecciona una opción',
        Icons.receipt_long_rounded,
      ),
      const SizedBox(height: 4),
      Text(
        '${_entrega.descripcion} · ${_empaque.label} para carga',
        style: GoogleFonts.inter(fontSize: 10, color: Colores.textTertiary),
      ),
      if (cobertura != null && cobertura.envios.isNotEmpty && cobertura.faltan.isNotEmpty)
        Text(
          'Precios solo de lo que falta por cubrir: ${cobertura.faltan.values.join(', ')}',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFB45309)),
        ),
      const SizedBox(height: 8),
    ];

    // Un solo producto: una lista con todos los servicios (paquete y carga),
    // sin resumen ni detalle aparte, que serían redundantes.
    if (nProductos == 1) {
      return [...encabezado, ..._buildListaUnica(results.first)];
    }

    final hayPaqueteCompleto = _totPaquete.any((t) => t.completo);
    String resumen(List<_CarrierTotal> l, String vacio) =>
        l.isEmpty ? vacio : '${l.length} paqueter${l.length != 1 ? 'ías' : 'ía'}';

    // Productos que ninguna paquetería cotizó (sin dimensiones o rechazados):
    // aviso visible arriba de los totales para que quede claro que el envío
    // que se agregue NO los incluye.
    final sinTarifa = results.where((pr) => pr.result?.options.isEmpty ?? true).toList();

    return [
      ...encabezado,
      if (sinTarifa.isNotEmpty) ...[
        _buildAvisoSinTarifa(sinTarifa),
        const SizedBox(height: 10),
      ],
      ShipSection(
        titulo: 'Paquetería normal (paquete)',
        icono: Icons.inventory_2_outlined,
        resumen: resumen(_totPaquete, 'ninguna aceptó los productos'),
        abierta: _paqueteAbierto,
        onToggle: () => setState(() => _paqueteAbierto = !_paqueteAbierto),
        children: [
          for (var i = 0; i < _totPaquete.length; i++)
            _buildTotalCard(_totPaquete[i], i == 0, _nTotales),
        ],
      ),
      const SizedBox(height: 8),
      ShipSection(
        titulo: 'Carga / Big Ticket',
        icono: Icons.local_shipping_outlined,
        resumen: resumen(_totCarga, 'sin opciones'),
        nota: hayPaqueteCompleto && _totCarga.isNotEmpty ? 'para bultos que no entran como paquete' : '',
        abierta: _cargaAbierta,
        onToggle: () => setState(() => _cargaAbierta = !_cargaAbierta),
        children: [
          for (var i = 0; i < _totCarga.length; i++)
            _buildTotalCard(_totCarga[i], i == 0, _nTotales),
        ],
      ),
      const SizedBox(height: 16),
      _buildSectionTitle('Detalle por producto', Icons.list_alt_rounded),
      const SizedBox(height: 8),
      ...results.map((pr) => _buildProductoCard(pr, nProductos)),
    ];
  }

  /// Envíos agregados (paquetería, importe y tapetes que cubre) y tapetes que
  /// faltan por cubrir; en verde si ya están todos.
  Widget _buildCobertura(CoberturaEnvios c) {
    final completo = c.faltan.isEmpty;
    final color = completo ? Colores.successColor : Colores.warningColor;
    final estilo = GoogleFonts.inter(fontSize: 11, color: Colores.textSecondary);
    return Container(
      key: _coberturaKey,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(completo ? Icons.check_circle_rounded : Icons.local_shipping_rounded,
              color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completo ? 'Todos los tapetes tienen envío:' : 'Envíos agregados:',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colores.textPrimary),
                ),
                const SizedBox(height: 4),
                for (final e in c.envios)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${e.carrier} · ${Utils.formatPrice(e.importe)}'
                      '${e.cubre != null ? ' · ${e.cubre!.values.join(', ')}' : ''}',
                      style: estilo,
                    ),
                  ),
                if (!completo) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Faltan por cubrir: ${c.faltan.values.join(', ')}',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFB45309)),
                  ),
                  Text(
                    'Agrega otra paquetería que los cotice (por ejemplo carga / Big Ticket), '
                    'o cierra y quedarán con la observación "${EnvioParcial.leyendaSinEnvio}".',
                    style: estilo,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Aviso de los productos que no se están cotizando (ninguna paquetería
  /// regresó tarifa) con su motivo.
  Widget _buildAvisoSinTarifa(List<_ProductQuote> sinTarifa) {
    final uno = sinTarifa.length == 1;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colores.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colores.warningColor.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colores.warningColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uno ? 'Este producto no se está cotizando:' : 'Estos productos no se están cotizando:',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colores.textPrimary),
                ),
                const SizedBox(height: 4),
                for (final pr in sinTarifa)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '• ${pr.product.productName}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (pr.result != null) TextSpan(text: ' ${pr.result!.dims}'),
                          TextSpan(
                            text: ' · ${pr.error ?? 'ninguna paquetería lo aceptó'}',
                            style: const TextStyle(color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                      style: GoogleFonts.inter(fontSize: 11, color: Colores.textSecondary),
                    ),
                  ),
                if (!widget.consulta) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Puedes agregar el envío de los demás; ${uno ? 'esta partida quedará' : 'estas partidas quedarán'} '
                    'con la observación "${EnvioParcial.leyendaSinEnvio}".',
                    style: GoogleFonts.inter(fontSize: 11, color: Colores.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de todos los servicios de un único producto, por modo. Cada
  /// tarifa se puede elegir (salvo en consulta); en ocurre lleva su propio
  /// selector de sucursal.
  List<Widget> _buildListaUnica(_ProductQuote pr) {
    final res = pr.result;
    final p = pr.product;
    final consulta = widget.consulta;
    final paquete = res?.paquete ?? const <ShippingOption>[];
    final carga = res?.carga ?? const <ShippingOption>[];
    String resumen(List<ShippingOption> l, String vacio) =>
        l.isEmpty ? vacio : '${l.length} opción${l.length != 1 ? 'es' : ''}';

    Widget tile(ShippingOption o, bool mejor) => ShipRateTile(
          option: o,
          cantidad: p.cantidad,
          mejorPrecio: mejor,
          onTap: consulta ? null : () => _seleccionarOpcion(p, o),
          branchSelector: (!consulta && o.esOcurre && o.branches.isNotEmpty)
              ? _buildBranchDropdown(_keyOpcion(o), o.branches)
              : null,
        );

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${p.productName}${res != null ? ' · ${res.dims}' : ''}',
                style: GoogleFonts.inter(fontSize: 11, color: Colores.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ShipTag(text: _guias(p.cantidad), color: Colores.primaryColor),
          ],
        ),
      ),
      if (pr.error != null)
        Text(pr.error!, style: GoogleFonts.inter(fontSize: 11, color: Colores.errorColor))
      else ...[
        ShipSection(
          titulo: 'Paquetería normal (paquete)',
          icono: Icons.inventory_2_outlined,
          resumen: resumen(paquete, 'ninguna aceptó este bulto'),
          abierta: _paqueteAbierto,
          onToggle: () => setState(() => _paqueteAbierto = !_paqueteAbierto),
          children: [for (var i = 0; i < paquete.length; i++) tile(paquete[i], i == 0)],
        ),
        const SizedBox(height: 8),
        ShipSection(
          titulo: 'Carga / Big Ticket',
          icono: Icons.local_shipping_outlined,
          resumen: resumen(carga, 'sin opciones'),
          nota: paquete.isNotEmpty && carga.isNotEmpty ? 'para bultos que no entran como paquete' : '',
          abierta: _cargaAbierta,
          onToggle: () => setState(() => _cargaAbierta = !_cargaAbierta),
          children: [for (var i = 0; i < carga.length; i++) tile(carga[i], i == 0)],
        ),
        if (res != null && res.rechazos.isNotEmpty) ...[
          const SizedBox(height: 4),
          ShipRechazosList(
            rechazos: res.rechazos,
            abiertoInicial: res.options.isEmpty,
            sujeto: 'producto',
          ),
        ],
      ],
    ];
  }

  /// Selector de sucursal (ocurre); la elección se guarda en `_branchSel`
  /// bajo `key` y se lee al agregar el envío.
  Widget _buildBranchDropdown(String key, List<ShippingBranch> branches) {
    final sel = _branchSel[key] ?? 0;
    return DropdownButtonFormField<int>(
      value: sel < branches.length ? sel : 0,
      isExpanded: true,
      isDense: true,
      style: GoogleFonts.inter(fontSize: 11, color: Colores.textPrimary),
      decoration: InputDecoration(
        labelText: 'Sucursal donde recoge el cliente',
        labelStyle: GoogleFonts.inter(fontSize: 10, color: Colores.textSecondary),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: [
        for (var bi = 0; bi < branches.length; bi++)
          DropdownMenuItem<int>(
            value: bi,
            child: Text(branches[bi].etiqueta, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) => setState(() => _branchSel[key] = v ?? 0),
    );
  }

  /// Card del resumen: total por paquetería y modo. Tocar = agregar envío
  /// (en modo consulta solo se muestra).
  Widget _buildTotalCard(_CarrierTotal t, bool esMejor, int nProductos) {
    final color = CarrierStyle.color(t.carrier);
    final consulta = widget.consulta;

    return Opacity(
      opacity: t.completo ? 1 : 0.7,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: consulta ? null : () => _seleccionarTotal(t),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(CarrierStyle.icon(t.carrier), color: color, size: 22),
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
                                  t.carrierDescription.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                                if (t.ocurre)
                                  const ShipTag(text: 'Ocurre', color: Colores.warningColor),
                                if (esMejor && t.completo)
                                  const ShipTag(text: 'Mejor precio', color: Colores.successColor),
                                if (!t.completo)
                                  ShipTag(
                                    text: 'solo ${t.productos} de $nProductos productos',
                                    color: Colores.errorColor,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_guias(t.guides)} en total · ${t.modo.label}',
                              style: GoogleFonts.inter(fontSize: 11, color: Colores.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Utils.formatPrice(t.total),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colores.textPrimary,
                            ),
                          ),
                          Text('MXN', style: GoogleFonts.inter(fontSize: 9, color: Colores.textTertiary)),
                        ],
                      ),
                      if (!consulta) ...[
                        const SizedBox(width: 4),
                        Icon(
                          t.completo ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                          color: t.completo ? Colores.primaryColor : Colores.warningColor,
                          size: 22,
                        ),
                      ],
                    ],
                  ),
                  // En ocurre, el vendedor elige la sucursal donde recogerá el
                  // cliente; se guarda en la observación de la partida ENVIO.
                  // En consulta solo se listan las sucursales.
                  if (t.ocurre) ...[
                    const SizedBox(height: 8),
                    if (t.branches.isEmpty)
                      Text(
                        'La paquetería no regresó lista de sucursales; confirmar el ocurre con ellos.',
                        style: GoogleFonts.inter(fontSize: 10, color: Colores.warningColor),
                      )
                    else if (consulta)
                      ShipBranchList(branches: t.branches)
                    else
                      _buildBranchDropdown(t.key, t.branches),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Detalle de un producto: dimensiones, tarifas por modo (máx. 6 cada uno)
  /// y motivos de rechazo.
  Widget _buildProductoCard(_ProductQuote pr, int nProductos) {
    final res = pr.result;
    final p = pr.product;
    final seleccionable = nProductos == 1 && !widget.consulta;
    final sinTarifas = res == null || res.options.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.productName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colores.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (res != null)
                      Text(
                        res.dims,
                        style: GoogleFonts.inter(fontSize: 10, color: Colores.textTertiary),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ShipTag(text: _guias(p.cantidad), color: Colores.primaryColor),
            ],
          ),
          if (pr.error != null) ...[
            const SizedBox(height: 6),
            Text(pr.error!, style: GoogleFonts.inter(fontSize: 10, color: Colores.errorColor)),
          ] else if (sinTarifas) ...[
            const SizedBox(height: 6),
            Text(
              'Ninguna paquetería aceptó este producto',
              style: GoogleFonts.inter(fontSize: 10, color: Colores.errorColor),
            ),
          ],
          if (res != null) ...[
            for (final modo in ShipModo.values)
              ..._buildDetalleModo(p, res, modo, seleccionable),
            if (res.rechazos.isNotEmpty) ...[
              const SizedBox(height: 4),
              ShipRechazosList(
                rechazos: res.rechazos,
                abiertoInicial: sinTarifas,
                sujeto: 'producto',
              ),
            ],
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDetalleModo(
    ProductShippingInfo p,
    ShippingQuoteResult res,
    ShipModo modo,
    bool seleccionable,
  ) {
    final lista = res.options.where((o) => o.modo == modo).take(6).toList();
    if (lista.isEmpty) return const [];
    return [
      const SizedBox(height: 8),
      ShipTag(
        text: modo.label,
        color: modo == ShipModo.carga ? Colores.warningColor : Colores.textSecondary,
      ),
      const SizedBox(height: 4),
      ...lista.map((o) => _buildDetalleRow(p, o, seleccionable)),
    ];
  }

  Widget _buildDetalleRow(ProductShippingInfo p, ShippingOption o, bool seleccionable) {
    final color = CarrierStyle.color(o.carrier);
    final tiempo = o.tiempoEntrega;
    final desc = [
      o.serviceDescription,
      if (o.esOcurre) o.entregaDesc,
      if (tiempo.isNotEmpty) tiempo,
    ].join(' · ');

    return InkWell(
      onTap: seleccionable ? () => _seleccionarOpcion(p, o) : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(CarrierStyle.icon(o.carrier), size: 14, color: color),
            const SizedBox(width: 4),
            SizedBox(
              width: 92,
              child: Text(
                o.carrierDescription.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                desc,
                style: GoogleFonts.inter(fontSize: 10, color: Colores.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              p.cantidad > 1
                  ? '${Utils.formatPrice(o.price)} × ${p.cantidad} = ${Utils.formatPrice(o.price * p.cantidad)}'
                  : Utils.formatPrice(o.price),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colores.textPrimary,
              ),
            ),
            if (seleccionable)
              const Icon(Icons.chevron_right_rounded, size: 14, color: Colores.textTertiary),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Formulario
  // ---------------------------------------------------------------------------

  /// Construye las cards de dimensiones para cada producto
  List<Widget> _buildProductDimensionCards() {
    return List.generate(_uniqueProducts.length, (index) {
      final product = _uniqueProducts[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colores.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${product.cantidad}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colores.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.productName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colores.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompactTextField(
                    controller: _largoControllers[index],
                    label: 'Largo (cm)',
                    icon: Icons.straighten_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactTextField(
                    controller: _altoControllers[index],
                    label: 'Alto (cm)',
                    icon: Icons.height_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCompactTextField(
                    controller: _anchoControllers[index],
                    label: 'Ancho (cm)',
                    icon: Icons.open_in_full_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactTextField(
                    controller: _pesoControllers[index],
                    label: 'Peso (kg)',
                    icon: Icons.scale_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colores.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colores.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildZipcodeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ZipcodeInfo? info,
    required bool isLoading,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 5,
          style: GoogleFonts.inter(
            color: Colores.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(color: Colores.textSecondary, fontSize: 12),
            prefixIcon: Icon(icon, color: Colores.primaryColor, size: 20),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : info != null
                    ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                    : null,
            counterText: '',
            filled: true,
            fillColor: Colors.grey[50],
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: info != null ? Colors.green.withOpacity(0.5) : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colores.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(5),
          ],
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requerido';
            if (value.length != 5) return '5 dígitos';
            return null;
          },
        ),
        if (info != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colores.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.place_rounded, color: Colores.primaryColor, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${info.locality}, ${info.state.name}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colores.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Campo de texto compacto para dimensiones
  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.inter(
        color: Colores.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colores.textSecondary, fontSize: 11),
        prefixIcon: Icon(icon, color: Colores.primaryColor, size: 18),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colores.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      // Vacío o en 0 no bloquea la cotización: ese producto se queda fuera
      // ("Faltan dimensiones") y los demás se cotizan (igual que en galería).
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (double.tryParse(value) == null) return 'Inválido';
        return null;
      },
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colores.gradientStart,
            Colores.gradientMiddle,
            Colores.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cotización de un producto (con las dimensiones ya editadas).
class _ProductQuote {
  final ProductShippingInfo product;
  final ShippingQuoteResult? result;

  /// Error previo a cotizar (dimensiones en cero).
  final String? error;

  _ProductQuote({required this.product, this.result, this.error});
}

/// Total por paquetería y modo: suma del mejor precio de cada producto ×
/// cantidad de guías.
class _CarrierTotal {
  final String key;
  final String carrier;
  final String carrierDescription;
  final ShipModo modo;
  double total = 0;
  int guides = 0;
  int productos = 0;
  bool completo = false;
  bool ocurre = false;
  List<ShippingBranch> branches = const [];
  final List<_Breakdown> breakdown = [];

  _CarrierTotal({
    required this.key,
    required this.carrier,
    required this.carrierDescription,
    required this.modo,
  });
}

/// Desglose de costo por producto dentro de un total.
class _Breakdown {
  final ProductShippingInfo product;
  final ShippingOption option;
  final double cost;

  _Breakdown({required this.product, required this.option, required this.cost});
}
