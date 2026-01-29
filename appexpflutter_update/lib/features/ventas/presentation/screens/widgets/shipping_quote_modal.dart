import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as org_math;
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/repositories/shipping_repository.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/zipcode_info.dart';

/// Modal para cotizar envíos desde la pantalla de pedidos
/// Permite seleccionar una paquetería y agregar el costo al total de la venta
class ShippingQuoteModal extends StatefulWidget {
  const ShippingQuoteModal({
    super.key,
    required this.productCount,
    required this.onShippingSelected,
  });

  /// Número de productos en el pedido
  final int productCount;

  /// Callback cuando se selecciona un envío
  /// Devuelve el precio del envío, carrier y descripción del servicio
  final void Function(double price, String carrier, String serviceDescription) onShippingSelected;

  /// Muestra el modal de cotización de envíos
  static Future<void> show({
    required BuildContext context,
    required int productCount,
    required void Function(double price, String carrier, String serviceDescription) onShippingSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShippingQuoteModal(
        productCount: productCount,
        onShippingSelected: onShippingSelected,
      ),
    );
  }

  @override
  State<ShippingQuoteModal> createState() => _ShippingQuoteModalState();
}

class _ShippingQuoteModalState extends State<ShippingQuoteModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _codigoPostalOrigenController = TextEditingController();
  final _codigoPostalDestinoController = TextEditingController();
  final _altoController = TextEditingController();
  final _largoController = TextEditingController();
  final _anchoController = TextEditingController();
  final _pesoController = TextEditingController();

  // Información de ubicación obtenida automáticamente
  ZipcodeInfo? _originInfo;
  ZipcodeInfo? _destinationInfo;
  String? _selectedOriginSuburb;
  String? _selectedDestinationSuburb;
  bool _isLoadingOrigin = false;
  bool _isLoadingDestination = false;

  final ShippingRepository _shippingRepository = ShippingRepository();

  bool _isLoading = false;
  Map<String, ShippingRateResponse>? _cotizaciones;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calcularDimensionesEstimadas();
  }

  void _calcularDimensionesEstimadas() {
    // Estimación básica: Asumimos un producto promedio de 30x20x10 cm (6000 cm3) y 1kg
    // y calculamos una caja cúbica aproximada para el volumen total.
    
    const double volPorProducto = 30 * 20 * 10; 
    final double volumenTotal = volPorProducto * widget.productCount;
    
    // Calculamos el lado de un cubo aproximado
    final double ladoAproximado = double.parse(
        (org_math.pow(volumenTotal, 1/3)).toStringAsFixed(0)
    );
    
    // Ajustamos dimensiones mínimas
    final double lado = ladoAproximado < 20 ? 20 : ladoAproximado;

    _largoController.text = lado.toString();
    _altoController.text = lado.toString();
    // La altura suele ser menor en muchas cajas, la reducimos un poco respecto al cubo
    _anchoController.text = (lado * 0.8).toStringAsFixed(0);
    
    // Peso estimado: 1.5 kg por producto (ajustable)
    _pesoController.text = (widget.productCount * 1.5).toString();
  }

  @override
  void dispose() {
    _codigoPostalOrigenController.dispose();
    _codigoPostalDestinoController.dispose();
    _altoController.dispose();
    _largoController.dispose();
    _anchoController.dispose();
    _pesoController.dispose();
    super.dispose();
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
      _cotizaciones = null;
    });

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
        height: double.parse(_altoController.text),
        length: double.parse(_largoController.text),
        width: double.parse(_anchoController.text),
        weight: double.parse(_pesoController.text),
        packageAmount: widget.productCount, // Cantidad de productos/paquetes
      );

      setState(() {
        _cotizaciones = cotizaciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener cotizaciones: ${e.toString()}';
        _isLoading = false;
      });
    }
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
      case 'tresguerras':
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
      case 'tresguerras':
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
      case 'tresguerras':
        return 'tresguerras';
      default:
        return carrier.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
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
                        '${widget.productCount} producto(s) en el pedido',
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
                    // Códigos Postales
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

                    // Dimensiones
                    _buildSectionTitle('Dimensiones y Peso', Icons.straighten_rounded),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _largoController,
                            label: 'Largo (cm)',
                            icon: Icons.straighten_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _altoController,
                            label: 'Alto (cm)',
                            icon: Icons.height_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _anchoController,
                            label: 'Ancho (cm)',
                            icon: Icons.open_in_full_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _pesoController,
                            label: 'Peso (kg)',
                            icon: Icons.scale_rounded,
                          ),
                        ),
                      ],
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
                        'Consultando paqueterías...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colores.textSecondary,
                        ),
                      ),
                    ],

                    // Resultados
                    if (_cotizaciones != null && !_isLoading) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('Selecciona una opción', Icons.receipt_long_rounded),
                      const SizedBox(height: 12),
                      ..._buildRateCards(),
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

  List<Widget> _buildRateCards() {
    final List<Widget> cards = [];

    // Ordenar carriers: PaqueteExpress primero
    final sortedEntries = _cotizaciones!.entries.toList()
      ..sort((a, b) {
        if (a.key.toLowerCase() == 'paquetexpress') return -1;
        if (b.key.toLowerCase() == 'paquetexpress') return 1;
        return 0;
      });

    for (final entry in sortedEntries) {
      final carrier = entry.key;
      final response = entry.value;

      if (response.error != null) {
        cards.add(_buildCarrierErrorCard(carrier, response.error!));
      } else if (response.data.isEmpty) {
        cards.add(_buildCarrierErrorCard(carrier, 'Sin cotizaciones disponibles'));
      } else {
        for (final rate in response.data) {
          cards.add(_buildSelectableRateCard(carrier, rate));
        }
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

  Widget _buildSelectableRateCard(String carrier, ShippingRate rate) {
    final carrierColor = _getCarrierColor(carrier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onShippingSelected(
              rate.totalPrice,
              carrier,
              '${rate.carrierDescription} - ${rate.serviceDescription}',
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
            child: Row(
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
                        rate.carrierDescription,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colores.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rate.serviceDescription,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colores.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: Colores.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            rate.deliveryEstimate,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colores.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
                        '\$${rate.totalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: carrier.toLowerCase() == 'dhl' ? Colors.black : Colors.white,
                        ),
                      ),
                      Text(
                        rate.currency,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
