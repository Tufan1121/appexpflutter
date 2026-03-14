import 'package:appexpflutter_update/features/cotizador_envio/data/datasources/envia_api_client.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_request.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/zipcode_info.dart';

class ShippingRepository {
  final EnviaApiClient _apiClient;

  ShippingRepository() : _apiClient = EnviaApiClient();

  /// Lista de carriers soportados
  static const List<String> carriers = ['paquetexpress', 'fedex', 'dhl', 'tresguerras'];

  /// Obtiene información del código postal desde la API de geocodes
  /// Solo necesita el código postal, devuelve ciudad, estado, colonias, etc.
  Future<ZipcodeInfo?> getZipcodeInfo(String zipCode) async {
    try {
      final response = await _apiClient.getZipcodeInfo(zipCode);
      
      if (response.statusCode == 200 && response.data != null) {
        // La API devuelve un array, tomamos el primer elemento
        final dataList = response.data as List<dynamic>;
        if (dataList.isNotEmpty) {
          return ZipcodeInfo.fromJson(dataList[0] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      // print('Error obteniendo info del código postal: $e');
      return null;
    }
  }

  /// Obtiene cotizaciones de los carriers en paralelo
  /// [packageAmount] es la cantidad de paquetes/productos a enviar
  Future<Map<String, ShippingRateResponse>> getShippingRates({
    required String originPostalCode,
    required String originCity,
    required String originState,
    required String originDistrict,
    required String destinationPostalCode,
    required String destinationCity,
    required String destinationState,
    required String destinationDistrict,
    required double height,
    required double length,
    required double width,
    required double weight,
    int packageAmount = 1, // Cantidad de paquetes
  }) async {
    // Crear las solicitudes en paralelo
    final futures = carriers.map((carrier) async {
      final request = _buildRequest(
        originPostalCode: originPostalCode,
        originCity: originCity,
        originState: originState,
        originDistrict: originDistrict,
        destinationPostalCode: destinationPostalCode,
        destinationCity: destinationCity,
        destinationState: destinationState,
        destinationDistrict: destinationDistrict,
        height: height,
        length: length,
        width: width,
        weight: weight,
        carrier: carrier,
        packageAmount: packageAmount,
      );

      try {
        // DEBUG: Imprimir el request para Tresguerras
        if (carrier == 'tresguerras') {
          print('=== DEBUG TRESGUERRAS REQUEST ===');
          print('JSON: ${request.toJson()}');
          print('================================');
        }
        
        final response = await _apiClient.post(
          '/ship/rate/',
          data: request.toJson(),
        );

        // DEBUG: Imprimir response para Tresguerras
        if (carrier == 'tresguerras') {
          print('=== DEBUG TRESGUERRAS RESPONSE ===');
          print('StatusCode: ${response.statusCode}');
          print('Data: ${response.data}');
          print('==================================');
        }

        if (response.statusCode == 200 && response.data != null) {
          return MapEntry(
            carrier,
            ShippingRateResponse.fromJson(response.data as Map<String, dynamic>),
          );
        } else {
          return MapEntry(
            carrier,
            ShippingRateResponse.error('Error al obtener cotización'),
          );
        }
      } catch (e) {
        // DEBUG: Imprimir error para Tresguerras
        if (carrier == 'tresguerras') {
          print('=== DEBUG TRESGUERRAS ERROR ===');
          print('Exception: $e');
          print('===============================');
        }
        return MapEntry(
          carrier,
          ShippingRateResponse.error('Error: ${e.toString()}'),
        );
      }
    }).toList();

    // Esperar todas las respuestas
    final rateResults = await Future.wait(futures);

    // Convertir a Map
    return Map.fromEntries(rateResults);
  }

  // NOTA: Ya no usamos _shouldUsePallet para otros carriers
  // Solo Tresguerras requiere tarima (type: 2)
  // Los demás carriers manejan sus propios límites y devuelven error si no pueden cotizar

  ShippingRateRequest _buildRequest({
    required String originPostalCode,
    required String originCity,
    required String originState,
    required String originDistrict,
    required String destinationPostalCode,
    required String destinationCity,
    required String destinationState,
    required String destinationDistrict,
    required double height,
    required double length,
    required double width,
    required double weight,
    required String carrier,
    required int packageAmount,
  }) {
    // Solo Tresguerras usa tarima (type: 2)
    // Los demás carriers (DHL, FedEx, Paquetexpress) usan caja (type: 1)
    final bool isTresguerras = carrier == 'tresguerras';
    
    // Para Tresguerras (LTL), asegurar peso mínimo de 30kg
    // Tresguerras no cotiza cargas muy ligeras
    double effectiveWeight = weight;
    if (isTresguerras && weight < 30) {
      effectiveWeight = 30;
      print('DEBUG TRESGUERRAS: Peso ajustado de $weight kg a 30 kg (mínimo LTL)');
    }
    
    return ShippingRateRequest(
      origin: Origin(
        postalCode: originPostalCode,
        city: originCity,
        state: originState,
        district: originDistrict,
        // phone ya tiene valor por defecto '5555555555' para Tresguerras
      ),
      destination: Destination(
        postalCode: destinationPostalCode,
        city: destinationCity,
        state: destinationState,
        district: destinationDistrict,
      ),
      packages: [
        Package(
          amount: packageAmount,
          type: isTresguerras ? 'pallet' : 'box', // Tresguerras = pallet, otros = box
          dimensions: Dimensions(
            length: length,
            width: width,
            height: height,
          ),
          weight: effectiveWeight,
        ),
      ],
      shipment: Shipment(
        carrier: carrier,
        type: isTresguerras ? 2 : 1, // 1 = caja, 2 = tarima/pallet (LTL)
      ),
      settings: Settings(),
    );
  }
}

