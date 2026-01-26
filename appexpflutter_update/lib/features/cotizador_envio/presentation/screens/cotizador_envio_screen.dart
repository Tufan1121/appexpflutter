import 'package:appexpflutter_update/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/repositories/shipping_repository.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
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
        return Colors.blue;
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping_rounded,
                                    color: Colors.white,
                                    size: 32,
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
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Remitente: $_userName',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ORIGEN Section
                          _buildSectionTitle('Origen'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildCityDropdown(
                                  value: _selectedOriginCityLabel,
                                  label: 'Ciudad Origen',
                                  onChanged: (val) => setState(() => _selectedOriginCityLabel = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // DESTINO Section
                          _buildSectionTitle('Destino'),
                          const SizedBox(height: 16),
                            Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildCityDropdown(
                                  value: _selectedDestinationCityLabel,
                                  label: 'Ciudad Destino',
                                  onChanged: (val) => setState(() => _selectedDestinationCityLabel = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Ubicaciones (CP)
                          _buildSectionTitle('Códigos Postales'),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 32),

                          // DIMENSIONES Section
                          _buildSectionTitle('Dimensiones (cm) y Peso (kg)'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _altoController,
                                  label: 'Alto',
                                  icon: Icons.height_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _largoController,
                                  label: 'Largo',
                                  icon: Icons.straighten_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _anchoController,
                                  label: 'Ancho',
                                  icon: Icons.open_in_full_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _pesoController,
                                  label: 'Peso',
                                  icon: Icons.scale_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

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
                                child: _buildPrimaryButton(
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

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
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
                              'Obteniendo cotizaciones de FedEx, DHL y Estafeta...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Resultados
                    if (_cotizaciones != null && !_isLoading) ...[
                      const SizedBox(height: 32),
                      _buildSectionTitle('Cotizaciones Disponibles'),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          floatingLabelStyle: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildCityDropdown({
    required String? value,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          dropdownColor: const Color(0xFF1E293B), // Slate 800
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withOpacity(0.9),
          ),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getCarrierColor(carrier).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCarrierIcon(carrier),
              color: _getCarrierColor(carrier),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCarrierName(carrier),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.red.shade300,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCarrierColor(carrier).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCarrierColor(carrier).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: _getCarrierColor(carrier).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCarrierIcon(carrier),
                  color: _getCarrierColor(carrier),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.carrierDescription,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rate.serviceDescription,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCarrierColor(carrier),
                      _getCarrierColor(carrier).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '\$${rate.totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: carrier.toLowerCase() == 'dhl' ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      rate.currency,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: carrier.toLowerCase() == 'dhl' 
                            ? Colors.black.withOpacity(0.7) 
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Detalles de entrega
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tiempo de entrega: ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  rate.deliveryEstimate,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (rate.deliveryDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    rate.deliveryDate!.date,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
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
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
}
