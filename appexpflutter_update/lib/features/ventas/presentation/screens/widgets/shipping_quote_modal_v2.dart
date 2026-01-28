import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/repositories/shipping_repository.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/zipcode_info.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/product_shipping_info.dart';

/// Modal mejorado para cotizar envíos con soporte para múltiples productos
/// Permite editar dimensiones por producto y cotiza en paralelo cuando hay productos diferentes
class ShippingQuoteModalV2 extends StatefulWidget {
  const ShippingQuoteModalV2({
    super.key,
    required this.products,
    required this.onShippingSelected,
  });

  /// Lista de productos con sus dimensiones y cantidades
  final List<ProductShippingInfo> products;

  /// Callback cuando se selecciona un envío
  /// Devuelve el precio total del envío, carrier, descripción del servicio y desglose
  final void Function(double totalPrice, String carrier, String serviceDescription, String breakdown) onShippingSelected;

  /// Muestra el modal de cotización de envíos
  static Future<void> show({
    required BuildContext context,
    required List<ProductShippingInfo> products,
    required void Function(double totalPrice, String carrier, String serviceDescription, String breakdown) onShippingSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShippingQuoteModalV2(
        products: products,
        onShippingSelected: onShippingSelected,
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

  bool _isLoading = false;
  String? _errorMessage;
  
  /// Cotizaciones agrupadas por carrier (el más barato de cada uno para todo el pedido)
  Map<String, _AggregatedQuote>? _aggregatedQuotes;

  /// Productos únicos (agrupados por clave)
  late List<ProductShippingInfo> _uniqueProducts;
  
  /// Total de items en el pedido
  int get _totalItems => _uniqueProducts.fold(0, (sum, p) => sum + p.cantidad);

  @override
  void initState() {
    super.initState();
    _groupProducts();
    _initControllers();
  }

  /// Agrupa productos por clave, sumando cantidades si son iguales
  void _groupProducts() {
    final Map<String, ProductShippingInfo> grouped = {};
    
    for (final product in widget.products) {
      if (grouped.containsKey(product.productKey)) {
        // Mismo producto, sumar cantidad
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

  /// Inicializa los controladores con los valores de cada producto
  void _initControllers() {
    _largoControllers = _uniqueProducts.map((p) => 
      TextEditingController(text: p.largo.toStringAsFixed(0))
    ).toList();
    
    _altoControllers = _uniqueProducts.map((p) => 
      TextEditingController(text: p.alto.toStringAsFixed(0))
    ).toList();
    
    _anchoControllers = _uniqueProducts.map((p) => 
      TextEditingController(text: p.ancho.toStringAsFixed(0))
    ).toList();
    
    _pesoControllers = _uniqueProducts.map((p) => 
      TextEditingController(text: p.peso.toString())
    ).toList();
  }

  @override
  void dispose() {
    _codigoPostalOrigenController.dispose();
    _codigoPostalDestinoController.dispose();
    for (final c in _largoControllers) { c.dispose(); }
    for (final c in _altoControllers) { c.dispose(); }
    for (final c in _anchoControllers) { c.dispose(); }
    for (final c in _pesoControllers) { c.dispose(); }
    super.dispose();
  }

  /// Obtiene los productos con las dimensiones actualizadas desde los controladores
  List<ProductShippingInfo> _getUpdatedProducts() {
    return List.generate(_uniqueProducts.length, (i) {
      final original = _uniqueProducts[i];
      return ProductShippingInfo(
        productKey: original.productKey,
        productName: original.productName,
        largo: double.tryParse(_largoControllers[i].text) ?? original.largo,
        alto: double.tryParse(_altoControllers[i].text) ?? original.alto,
        ancho: double.tryParse(_anchoControllers[i].text) ?? original.ancho,
        peso: double.tryParse(_pesoControllers[i].text) ?? original.peso,
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
      setState(() {
        _originInfo = info;
        _selectedOriginSuburb = info?.suburbs.isNotEmpty == true ? info!.suburbs.first : null;
        _isLoadingOrigin = false;
      });
    } catch (e) {
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
      setState(() {
        _destinationInfo = info;
        _selectedDestinationSuburb = info?.suburbs.isNotEmpty == true ? info!.suburbs.first : null;
        _isLoadingDestination = false;
      });
    } catch (e) {
      setState(() {
        _destinationInfo = null;
        _isLoadingDestination = false;
      });
    }
  }

  /// Cotiza envíos para todos los productos (en paralelo si son diferentes)
  Future<void> _calcularCotizacion() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar códigos postales
    if (_codigoPostalOrigenController.text.trim().length != 5 ||
        _codigoPostalDestinoController.text.trim().length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Los códigos postales deben tener 5 dígitos', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_originInfo == null || _destinationInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Espera a que se cargue la información de los códigos postales', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedOriginSuburb == null || _selectedDestinationSuburb == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo obtener información de los códigos postales', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _aggregatedQuotes = null;
    });

    try {
      // Obtener productos con dimensiones actualizadas
      final products = _getUpdatedProducts();
      
      // Si hay un solo tipo de producto, cotización simple
      // Si hay varios tipos, cotizar en paralelo cada uno
      
      if (products.length == 1) {
        // Caso simple: un solo tipo de producto
        await _cotizarProductoUnico(products.first);
      } else {
        // Caso múltiple: varios tipos de productos, cotizar en paralelo
        await _cotizarMultiplesProductos(products);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener cotizaciones: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Cotización para un solo tipo de producto (múltiples unidades)
  Future<void> _cotizarProductoUnico(ProductShippingInfo product) async {
    final cotizaciones = await _shippingRepository.getShippingRates(
      originPostalCode: _codigoPostalOrigenController.text.trim(),
      originCity: _originInfo!.locality,
      originState: _originInfo!.stateCode2,
      originDistrict: _selectedOriginSuburb!,
      destinationPostalCode: _codigoPostalDestinoController.text.trim(),
      destinationCity: _destinationInfo!.locality,
      destinationState: _destinationInfo!.stateCode2,
      destinationDistrict: _selectedDestinationSuburb!,
      height: product.alto,
      length: product.largo,
      width: product.ancho,
      weight: product.peso,
      packageAmount: product.cantidad,
    );

    // Convertir a cotizaciones agregadas
    final aggregated = <String, _AggregatedQuote>{};
    
    for (final entry in cotizaciones.entries) {
      final carrier = entry.key;
      final response = entry.value;
      
      if (response.error != null || response.data.isEmpty) {
        aggregated[carrier] = _AggregatedQuote(
          carrier: carrier,
          totalCost: 0,
          productBreakdown: [],
          hasError: true,
          errorMessage: response.error ?? 'Sin cotizaciones disponibles',
          bestRate: null,
        );
      } else {
        // Tomar la tarifa más barata de este carrier
        final bestRate = response.data.reduce((a, b) => 
          a.totalPrice < b.totalPrice ? a : b
        );
        
        aggregated[carrier] = _AggregatedQuote(
          carrier: carrier,
          totalCost: bestRate.totalPrice,
          productBreakdown: [
            _ProductBreakdown(
              product: product,
              cost: bestRate.totalPrice,
              rate: bestRate,
            ),
          ],
          hasError: false,
          bestRate: bestRate,
        );
      }
    }
    
    _aggregatedQuotes = aggregated;
  }

  /// Cotización para múltiples tipos de productos (en paralelo)
  Future<void> _cotizarMultiplesProductos(List<ProductShippingInfo> products) async {
    // Cotizar cada producto en paralelo
    final futures = products.map((product) async {
      try {
        final cotizaciones = await _shippingRepository.getShippingRates(
          originPostalCode: _codigoPostalOrigenController.text.trim(),
          originCity: _originInfo!.locality,
          originState: _originInfo!.stateCode2,
          originDistrict: _selectedOriginSuburb!,
          destinationPostalCode: _codigoPostalDestinoController.text.trim(),
          destinationCity: _destinationInfo!.locality,
          destinationState: _destinationInfo!.stateCode2,
          destinationDistrict: _selectedDestinationSuburb!,
          height: product.alto,
          length: product.largo,
          width: product.ancho,
          weight: product.peso,
          packageAmount: product.cantidad,
        );
        return MapEntry(product, cotizaciones);
      } catch (e) {
        return MapEntry(product, <String, ShippingRateResponse>{});
      }
    }).toList();

    final results = await Future.wait(futures);
    
    // Agregar resultados por carrier
    final aggregated = <String, _AggregatedQuote>{};
    
    for (final carrier in ShippingRepository.carriers) {
      double totalCost = 0;
      final breakdowns = <_ProductBreakdown>[];
      bool hasError = false;
      String? errorMsg;
      ShippingRate? overallBestRate;
      
      for (final result in results) {
        final product = result.key;
        final carrierResponse = result.value[carrier];
        
        if (carrierResponse == null || carrierResponse.error != null || carrierResponse.data.isEmpty) {
          hasError = true;
          errorMsg = carrierResponse?.error ?? 'Error en producto ${product.productName}';
          break;
        }
        
        // Tomar la tarifa más barata para este producto
        final bestRate = carrierResponse.data.reduce((a, b) => 
          a.totalPrice < b.totalPrice ? a : b
        );
        
        totalCost += bestRate.totalPrice;
        breakdowns.add(_ProductBreakdown(
          product: product,
          cost: bestRate.totalPrice,
          rate: bestRate,
        ));
        
        // Guardar el rate para mostrar info general
        overallBestRate ??= bestRate;
      }
      
      aggregated[carrier] = _AggregatedQuote(
        carrier: carrier,
        totalCost: totalCost,
        productBreakdown: breakdowns,
        hasError: hasError,
        errorMessage: errorMsg,
        bestRate: overallBestRate,
      );
    }
    
    _aggregatedQuotes = aggregated;
  }

  IconData _getCarrierIcon(String carrier) {
    switch (carrier.toLowerCase()) {
      case 'paquetexpress':
        return Icons.inventory_2_rounded;
      case 'fedex':
        return Icons.local_shipping_rounded;
      case 'dhl':
        return Icons.flight_rounded;
      case 'estafeta':
        return Icons.delivery_dining_rounded;
      case 'redpack':
        return Icons.markunread_mailbox_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  Color _getCarrierColor(String carrier) {
    switch (carrier.toLowerCase()) {
      case 'paquetexpress':
        return const Color(0xFF1976D2);
      case 'fedex':
        return const Color(0xFF4D148C);
      case 'dhl':
        return const Color(0xFFFFCC00);
      case 'estafeta':
        return const Color(0xFF00A651);
      case 'redpack':
        return const Color(0xFFD32F2F);
      default:
        return Colores.primaryColor;
    }
  }

  String _getCarrierName(String carrier) {
    switch (carrier.toLowerCase()) {
      case 'paquetexpress':
        return 'Paquetexpress';
      case 'fedex':
        return 'FedEx';
      case 'dhl':
        return 'DHL Express';
      case 'estafeta':
        return 'Estafeta';
      case 'redpack':
        return 'Redpack';
      default:
        return carrier.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Códigos Postales - PRIMERO según el orden original
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
                    
                    // Dimensiones y Peso por producto - SEGUNDO según el orden original
                    _buildSectionTitle('Dimensiones y Peso por Producto', Icons.straighten_rounded),
                    const SizedBox(height: 12),
                    ..._buildProductDimensionCards(),
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
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
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
                        _uniqueProducts.length > 1 
                            ? 'Cotizando ${_uniqueProducts.length} productos en paralelo...'
                            : 'Consultando paqueterías...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colores.textSecondary,
                        ),
                      ),
                    ],

                    // Resultados
                    if (_aggregatedQuotes != null && !_isLoading) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('Selecciona una opción', Icons.receipt_long_rounded),
                      const SizedBox(height: 12),
                      ..._buildQuoteCards(),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            // Header del producto
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
            
            // Primera fila: Largo y Alto (orden original del formulario)
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
            
            // Segunda fila: Ancho y Peso (orden original del formulario)
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

  List<Widget> _buildQuoteCards() {
    final List<Widget> cards = [];

    // Ordenar carriers: PaqueteExpress primero, luego por precio
    final sortedEntries = _aggregatedQuotes!.entries.toList()
      ..sort((a, b) {
        // Errores al final
        if (a.value.hasError && !b.value.hasError) return 1;
        if (!a.value.hasError && b.value.hasError) return -1;
        
        // PaqueteExpress primero
        if (a.key.toLowerCase() == 'paquetexpress') return -1;
        if (b.key.toLowerCase() == 'paquetexpress') return 1;
        
        // Luego por precio
        return a.value.totalCost.compareTo(b.value.totalCost);
      });

    for (final entry in sortedEntries) {
      final carrier = entry.key;
      final quote = entry.value;

      if (quote.hasError) {
        cards.add(_buildCarrierErrorCard(carrier, quote.errorMessage ?? 'Error'));
      } else {
        cards.add(_buildSelectableQuoteCard(carrier, quote));
      }
    }

    return cards;
  }

  Widget _buildCarrierErrorCard(String carrier, String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_getCarrierIcon(carrier), color: Colors.grey[400], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCarrierName(carrier),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  error,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableQuoteCard(String carrier, _AggregatedQuote quote) {
    final carrierColor = _getCarrierColor(carrier);
    final hasMultipleProducts = quote.productBreakdown.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final description = quote.bestRate != null 
                ? '${quote.bestRate!.carrierDescription} - ${quote.bestRate!.serviceDescription}'
                : _getCarrierName(carrier);
            
            // Generar el desglose por producto
            String breakdown = '';
            if (hasMultipleProducts) {
              final breakdownLines = quote.productBreakdown.map((b) => 
                '  • ${b.product.productName} (${b.product.cantidad}u): \$${b.cost.toStringAsFixed(0)} MXN'
              ).toList();
              breakdown = 'Desglose:\n${breakdownLines.join('\n')}';
            }
            
            widget.onShippingSelected(
              quote.totalCost,
              carrier,
              description,
              breakdown,
            );
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del carrier
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: carrierColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCarrierIcon(carrier),
                        color: carrierColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.bestRate?.carrierDescription ?? _getCarrierName(carrier),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colores.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            quote.bestRate?.serviceDescription ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colores.textSecondary,
                            ),
                          ),
                          if (quote.bestRate != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: Colores.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  quote.bestRate!.deliveryEstimate,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colores.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [carrierColor, carrierColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '\$${quote.totalCost.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: carrier.toLowerCase() == 'dhl' ? Colors.black : Colors.white,
                            ),
                          ),
                          Text(
                            'MXN',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: carrier.toLowerCase() == 'dhl' 
                                  ? Colors.black.withOpacity(0.7) 
                                  : Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colores.textSecondary,
                    ),
                  ],
                ),
                
                // Desglose por producto (si hay múltiples)
                if (hasMultipleProducts) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Desglose por producto:',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colores.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...quote.productBreakdown.map((breakdown) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: carrierColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${breakdown.product.cantidad}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: carrierColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            breakdown.product.productName,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colores.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          Utils.formatPrice(breakdown.cost),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: carrierColor,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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
            labelStyle: GoogleFonts.inter(
              color: Colores.textSecondary,
              fontSize: 12,
            ),
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
        labelStyle: GoogleFonts.inter(
          color: Colores.textSecondary,
          fontSize: 11,
        ),
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
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requerido';
        final number = double.tryParse(value);
        if (number == null || number <= 0) return 'Inválido';
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

/// Cotización agregada por carrier (suma de todos los productos)
class _AggregatedQuote {
  final String carrier;
  final double totalCost;
  final List<_ProductBreakdown> productBreakdown;
  final bool hasError;
  final String? errorMessage;
  final ShippingRate? bestRate;

  _AggregatedQuote({
    required this.carrier,
    required this.totalCost,
    required this.productBreakdown,
    required this.hasError,
    this.errorMessage,
    this.bestRate,
  });
}

/// Desglose de costo por producto
class _ProductBreakdown {
  final ProductShippingInfo product;
  final double cost;
  final ShippingRate rate;

  _ProductBreakdown({
    required this.product,
    required this.cost,
    required this.rate,
  });
}
