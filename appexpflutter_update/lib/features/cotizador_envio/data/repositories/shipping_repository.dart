import 'package:appexpflutter_update/features/cotizador_envio/data/datasources/envia_api_client.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_request.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/zipcode_info.dart';

class ShippingRepository {
  final EnviaApiClient _apiClient;

  ShippingRepository() : _apiClient = EnviaApiClient();

  /// Lista de carriers soportados
  static const List<String> carriers = ['paquetexpress', 'fedex', 'dhl', 'redpack'];

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

  /// Obtiene cotizaciones de los 3 carriers en paralelo
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
  }) async {
    // Crear las 3 solicitudes en paralelo
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
      );

      try {
        final response = await _apiClient.post(
          '/ship/rate/',
          data: request.toJson(),
        );

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
  }) {
    return ShippingRateRequest(
      origin: Origin(
        postalCode: originPostalCode,
        city: originCity,
        state: originState,
        district: originDistrict,
      ),
      destination: Destination(
        postalCode: destinationPostalCode,
        city: destinationCity,
        state: destinationState,
        district: destinationDistrict,
      ),
      packages: [
        Package(
          dimensions: Dimensions(
            length: length,
            width: width,
            height: height,
          ),
          weight: weight,
        ),
      ],
      shipment: Shipment(carrier: carrier),
      settings: Settings(),
    );
  }
}
