import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/repositories/shipping_repository.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_quote.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/zipcode_info.dart';
import 'package:appexpflutter_update/features/cotizador_envio/presentation/widgets/ship_widgets.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cotizador de envíos individual (menú principal): un bulto con sus
/// dimensiones, cotizado como paquete y como carga con todas las
/// paqueterías. Misma lógica que `busquedaglobal.html` en galería.
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
  ShippingQuoteResult? _resultado;

  /// Entrega con la que se cotizó `_resultado` (para el texto del resumen).
  ShipEntrega _entregaCotizada = ShipEntrega.domicilio;
  bool _paqueteAbierto = true;
  bool _cargaAbierta = true;
  String? _errorMessage;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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
        backgroundColor: Colores.errorColor,
      ),
    );
  }

  Future<void> _calcularCotizacion() async {
    FocusScope.of(context).unfocus(); // Cerrar teclado al iniciar cotización
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultado = null;
    });

    try {
      final resultado = await _shippingRepository.quote(
        route: ShipRoute(
          originPostalCode: _codigoPostalOrigenController.text.trim(),
          originCity: _originInfo!.locality,
          originState: _originInfo!.stateCode2,
          originDistrict: _selectedOriginSuburb!,
          destinationPostalCode: _codigoPostalDestinoController.text.trim(),
          destinationCity: _destinationInfo!.locality,
          destinationState: _destinationInfo!.stateCode2,
          destinationDistrict: _selectedDestinationSuburb!,
        ),
        largo: double.parse(_largoController.text),
        ancho: double.parse(_anchoController.text),
        alto: double.parse(_altoController.text),
        peso: double.parse(_pesoController.text),
        empaque: _empaque,
        entrega: _entrega,
      );

      if (!mounted) return;
      setState(() {
        _resultado = resultado;
        _entregaCotizada = _entrega;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      _originInfo = null;
      _destinationInfo = null;
      _selectedOriginSuburb = null;
      _selectedDestinationSuburb = null;
      _resultado = null;
      _errorMessage = null;
      _empaque = ShipEmpaque.roll;
      _entrega = ShipEntrega.domicilio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: GeometricalBackground(
          child: Column(
            children: [
              // Custom App Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
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
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // CARD FORMULARIO
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

                              _buildSectionTitle('Dimensiones y Peso', Icons.straighten_rounded),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _largoController,
                                      label: 'Largo (cm)',
                                      icon: Icons.straighten_rounded,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _altoController,
                                      label: 'Alto (cm)',
                                      icon: Icons.height_rounded,
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
                              const SizedBox(height: 20),

                              _buildSectionTitle('Empaque y entrega', Icons.local_shipping_outlined),
                              const SizedBox(height: 12),
                              ShipOptionsSelector(
                                empaque: _empaque,
                                entrega: _entrega,
                                enabled: !_isLoading,
                                onEmpaqueChanged: (v) => setState(() => _empaque = v),
                                onEntregaChanged: (v) => setState(() => _entrega = v),
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
                                'Consultando paqueterías (paquete y carga)...',
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
                      if (_resultado != null && !_isLoading) ...[
                        const SizedBox(height: 24),
                        _buildResultados(_resultado!),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bloques Paquete / Carga con cada tarifa y los motivos de rechazo, en
  /// una card blanca sobre el fondo degradado.
  Widget _buildResultados(ShippingQuoteResult r) {
    final paquete = r.paquete;
    final carga = r.carga;
    String resumen(List<ShippingOption> l, String vacio) =>
        l.isEmpty ? vacio : '${l.length} opción${l.length != 1 ? 'es' : ''}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colores.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colores.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cotizaciones Disponibles',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colores.textPrimary,
                      ),
                    ),
                    Text(
                      '${r.dims} · ${_entregaCotizada.descripcion}',
                      style: GoogleFonts.inter(fontSize: 11, color: Colores.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (r.options.isEmpty) ...[
            const Icon(Icons.sentiment_dissatisfied_rounded, size: 36, color: Colores.textTertiary),
            const SizedBox(height: 6),
            Text(
              'Ninguna paquetería aceptó este paquete (${r.dims}) en esta ruta',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: Colores.textSecondary),
            ),
            const SizedBox(height: 8),
          ] else ...[
            ShipSection(
              titulo: 'Paquetería normal (paquete)',
              icono: Icons.inventory_2_outlined,
              resumen: resumen(paquete, 'ninguna aceptó este bulto'),
              abierta: _paqueteAbierto,
              onToggle: () => setState(() => _paqueteAbierto = !_paqueteAbierto),
              children: [
                for (var i = 0; i < paquete.length; i++)
                  ShipRateTile(option: paquete[i], mejorPrecio: i == 0),
              ],
            ),
            const SizedBox(height: 8),
            ShipSection(
              titulo: 'Carga / Big Ticket',
              icono: Icons.local_shipping_outlined,
              resumen: resumen(carga, 'sin opciones'),
              nota: paquete.isNotEmpty && carga.isNotEmpty ? 'para bultos que no entran como paquete' : '',
              abierta: _cargaAbierta,
              onToggle: () => setState(() => _cargaAbierta = !_cargaAbierta),
              children: [
                for (var i = 0; i < carga.length; i++)
                  ShipRateTile(option: carga[i], mejorPrecio: i == 0),
              ],
            ),
          ],
          if (r.rechazos.isNotEmpty)
            ShipRechazosList(
              rechazos: r.rechazos,
              abiertoInicial: r.options.isEmpty,
              sujeto: 'paquete',
            ),
        ],
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

  /// Widget para campo de código postal con información de ubicación automática
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
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colores.primaryColor),
                      ),
                    ),
                  )
                : info != null
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 20,
                      )
                    : null,
            counterText: '',
            filled: true,
            fillColor: Colores.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colores.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: info != null ? Colors.green.withValues(alpha: 0.5) : Colores.inputBorder,
              ),
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(5),
          ],
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Código postal requerido';
            }
            if (value.length != 5) {
              return 'Debe tener 5 dígitos';
            }
            return null;
          },
        ),
        // Información de ubicación (la colonia se elige automáticamente)
        if (info != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colores.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colores.primaryColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.place_rounded,
                  color: Colores.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${info.locality}, ${info.state.name}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colores.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (controller.text.length == 5 && !isLoading) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colores.errorColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colores.errorColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colores.errorColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Código postal no encontrado',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colores.errorColor,
                    ),
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
