import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/repositories/shipping_repository.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CotizadorEnvioScreen extends StatefulWidget {
  const CotizadorEnvioScreen({super.key});

  @override
  State<CotizadorEnvioScreen> createState() => _CotizadorEnvioScreenState();
}

class _CotizadorEnvioScreenState extends State<CotizadorEnvioScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _codigoPostalOrigenController = TextEditingController();
  final _codigoPostalDestinoController = TextEditingController();
  final _altoController = TextEditingController();
  final _largoController = TextEditingController();
  final _anchoController = TextEditingController();
  final _pesoController = TextEditingController();

  // Ciudades seleccionadas (Labels)
  String? _selectedOriginCityLabel;
  String? _selectedDestinationCityLabel;

  final ShippingRepository _shippingRepository = ShippingRepository();

  bool _isLoading = false;
  Map<String, ShippingRateResponse>? _cotizaciones;
  String? _errorMessage;
  String _userName = '';

  // Lista de Ciudades predefinidas que mapean a Ciudad y Estado
  final List<Map<String, String>> _availableCities = [
    {'label': 'Monterrey, NL', 'city': 'Monterrey', 'state': 'NL'},
    {'label': 'San Pedro Garza García, NL', 'city': 'San Pedro Garza García', 'state': 'NL'},
    {'label': 'Apodaca, NL', 'city': 'Apodaca', 'state': 'NL'},
    {'label': 'Guadalupe, NL', 'city': 'Guadalupe', 'state': 'NL'},
    {'label': 'Ciudad de México, CDMX', 'city': 'Ciudad de México', 'state': 'CMX'},
    {'label': 'Guadalajara, JAL', 'city': 'Guadalajara', 'state': 'JAL'},
    {'label': 'Zapopan, JAL', 'city': 'Zapopan', 'state': 'JAL'},
    {'label': 'Puebla, PUE', 'city': 'Puebla', 'state': 'PUE'},
    {'label': 'Querétaro, QRO', 'city': 'Querétaro', 'state': 'QRO'},
    {'label': 'Mérida, YUC', 'city': 'Mérida', 'state': 'YUC'},
    {'label': 'León, GTO', 'city': 'León', 'state': 'GTO'},
    {'label': 'Tijuana, BC', 'city': 'Tijuana', 'state': 'BC'},
    {'label': 'Hermosillo, SON', 'city': 'Hermosillo', 'state': 'SON'},
    {'label': 'Saltillo, COAH', 'city': 'Saltillo', 'state': 'COAH'},
    {'label': 'San Luis Potosí, SLP', 'city': 'San Luis Potosí', 'state': 'SLP'},
    {'label': 'Toluca, MEX', 'city': 'Toluca', 'state': 'MEX'},
    {'label': 'Cancún, QROO', 'city': 'Cancún', 'state': 'QROO'},
    {'label': 'Veracruz, VER', 'city': 'Veracruz', 'state': 'VER'},
    {'label': 'Chihuahua, CHIH', 'city': 'Chihuahua', 'state': 'CHIH'},
    {'label': 'Aguascalientes, AGS', 'city': 'Aguascalientes', 'state': 'AGS'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'Usuario';
    });
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

  Future<void> _calcularCotizacion() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedOriginCityLabel == null || _selectedDestinationCityLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona la ciudad de origen y destino', style: GoogleFonts.inter()),
          backgroundColor: Colores.errorColor,
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
      // Buscar los objetos de ciudad seleccionados
      final originCityData = _availableCities.firstWhere((c) => c['label'] == _selectedOriginCityLabel);
      final destCityData = _availableCities.firstWhere((c) => c['label'] == _selectedDestinationCityLabel);

      final cotizaciones = await _shippingRepository.getShippingRates(
        userName: _userName,
        originPostalCode: _codigoPostalOrigenController.text,
        originCity: originCityData['city']!,
        originState: originCityData['state']!,
        destinationPostalCode: _codigoPostalDestinoController.text,
        destinationCity: destCityData['city']!,
        destinationState: destCityData['state']!,
        height: double.parse(_altoController.text),
        length: double.parse(_largoController.text),
        width: double.parse(_anchoController.text),
        weight: double.parse(_pesoController.text),
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

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _codigoPostalOrigenController.clear();
    _codigoPostalDestinoController.clear();
    _altoController.clear();
    _largoController.clear();
    _anchoController.clear();
    _pesoController.clear();
    setState(() {
      _selectedOriginCityLabel = null;
      _selectedDestinationCityLabel = null;
      _cotizaciones = null;
      _errorMessage = null;
    });
  }

  IconData _getCarrierIcon(String carrier) {
    switch (carrier.toLowerCase()) {
      case 'fedex':
        return Icons.local_shipping_rounded;
      case 'dhl':
        return Icons.flight_rounded;
      case 'estafeta':
        return Icons.delivery_dining_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  Color _getCarrierColor(String carrier) {
    switch (carrier.toLowerCase()) {
      case 'fedex':
        return const Color(0xFF4D148C); // FedEx purple
      case 'dhl':
        return const Color(0xFFFFCC00); // DHL yellow
      case 'estafeta':
        return const Color(0xFF00A651); // Estafeta green
      default:
        return Colores.primaryColor;
    }
  }

  String _getCarrierName(String carrier) {
    switch (carrier.toLowerCase()) {
      case 'fedex':
        return 'FedEx';
      case 'dhl':
        return 'DHL Express';
      case 'estafeta':
        return 'Estafeta';
      default:
        return carrier.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GeometricalBackground(
        child: Column(
          children: [
            // Custom App Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Text(
                        'Cotizador de Envíos',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CARD FORMULARIO - Estilo premium blanco
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colores.gradientEnd.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header con icono gradient
                            Row(
                              children: [
                                Container(
                                  height: 56,
                                  width: 56,
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
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colores.primaryColor.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Datos del Paquete',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colores.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Remitente: $_userName',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colores.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // ORIGEN Section
                            _buildSectionTitle('Origen', Icons.flight_takeoff_rounded),
                            const SizedBox(height: 12),
                            _buildCityDropdown(
                              value: _selectedOriginCityLabel,
                              label: 'Selecciona ciudad de origen',
                              onChanged: (val) => setState(() => _selectedOriginCityLabel = val),
                            ),
                            const SizedBox(height: 20),

                            // DESTINO Section
                            _buildSectionTitle('Destino', Icons.flight_land_rounded),
                            const SizedBox(height: 12),
                            _buildCityDropdown(
                              value: _selectedDestinationCityLabel,
                              label: 'Selecciona ciudad de destino',
                              onChanged: (val) => setState(() => _selectedDestinationCityLabel = val),
                            ),
                            const SizedBox(height: 20),

                            // Códigos Postales
                            _buildSectionTitle('Códigos Postales', Icons.pin_drop_rounded),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _codigoPostalOrigenController,
                                    label: 'CP Origen',
                                    icon: Icons.location_on_outlined,
                                    keyboardType: TextInputType.number,
                                    maxLength: 5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _codigoPostalDestinoController,
                                    label: 'CP Destino',
                                    icon: Icons.my_location_rounded,
                                    keyboardType: TextInputType.number,
                                    maxLength: 5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // DIMENSIONES Section
                            _buildSectionTitle('Dimensiones y Peso', Icons.straighten_rounded),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _altoController,
                                    label: 'Alto (cm)',
                                    icon: Icons.height_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _largoController,
                                    label: 'Largo (cm)',
                                    icon: Icons.straighten_rounded,
                                    keyboardType: TextInputType.number,
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
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _pesoController,
                                    label: 'Peso (kg)',
                                    icon: Icons.scale_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildOutlineButton(
                                    label: 'Limpiar',
                                    icon: Icons.refresh_rounded,
                                    onPressed: _limpiarFormulario,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _buildGradientButton(
                                    label: _isLoading ? 'Cotizando...' : 'Cotizar Envío',
                                    icon: _isLoading ? Icons.hourglass_top_rounded : Icons.calculate_rounded,
                                    onPressed: _isLoading ? () {} : _calcularCotizacion,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colores.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colores.errorColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colores.errorColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  color: Colores.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Loading indicator
                    if (_isLoading) ...[
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Consultando FedEx, DHL y Estafeta...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Resultados
                    if (_cotizaciones != null && !_isLoading) ...[
                      const SizedBox(height: 24),
                      // Título de resultados
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cotizaciones Disponibles',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._cotizaciones!.entries.map((entry) {
                        final carrier = entry.key;
                        final response = entry.value;

                        if (response.error != null) {
                          return _buildCarrierErrorCard(carrier, response.error!);
                        }

                        if (response.data.isEmpty) {
                          return _buildCarrierErrorCard(carrier, 'Sin cotizaciones disponibles');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: response.data.map((rate) {
                            return _buildRateCard(carrier, rate);
                          }).toList(),
                        );
                      }),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colores.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colores.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: GoogleFonts.inter(
        color: Colores.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: Colores.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: Colores.primaryColor,
          size: 20,
        ),
        counterText: '',
        filled: true,
        fillColor: Colores.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colores.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colores.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        if (keyboardType == TextInputType.number) {
          final number = double.tryParse(value);
          if (number == null || number <= 0) {
            return 'Inválido';
          }
        }
        return null;
      },
    );
  }

  Widget _buildCityDropdown({
    required String? value,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colores.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colores.inputBorder,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            label,
            style: GoogleFonts.inter(
              color: Colores.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colores.primaryColor,
          ),
          style: GoogleFonts.inter(
            color: Colores.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          items: _availableCities.map((cityData) {
            return DropdownMenuItem<String>(
              value: cityData['label'],
              child: Text(cityData['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCarrierErrorCard(String carrier, String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
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
              color: _getCarrierColor(carrier).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCarrierIcon(carrier),
              color: _getCarrierColor(carrier),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCarrierName(carrier),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colores.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colores.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(String carrier, ShippingRate rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _getCarrierColor(carrier).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con carrier y precio
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCarrierColor(carrier).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCarrierIcon(carrier),
                  color: _getCarrierColor(carrier),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.carrierDescription,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colores.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rate.serviceDescription,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colores.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCarrierColor(carrier),
                      _getCarrierColor(carrier).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getCarrierColor(carrier).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '\$${rate.totalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: carrier.toLowerCase() == 'dhl' ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      rate.currency,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: carrier.toLowerCase() == 'dhl' 
                            ? Colors.black.withOpacity(0.7) 
                            : Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Detalles de entrega
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colores.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colores.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  rate.deliveryEstimate,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colores.textPrimary,
                  ),
                ),
                if (rate.deliveryDate != null) ...[
                  const Spacer(),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colores.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    rate.deliveryDate!.date,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colores.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colores.inputBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colores.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colores.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
