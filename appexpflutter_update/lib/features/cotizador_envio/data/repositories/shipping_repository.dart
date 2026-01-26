import 'package:appexpflutter_update/features/cotizador_envio/data/datasources/envia_api_client.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_request.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/shipping_rate_response.dart';

class ShippingRepository {
  final EnviaApiClient _apiClient;

  ShippingRepository() : _apiClient = EnviaApiClient();

  /// Lista de carriers soportados
  static const List<String> carriers = ['fedex', 'dhl', 'estafeta'];

  /// Obtiene cotizaciones de los 3 carriers en paralelo
  Future<Map<String, ShippingRateResponse>> getShippingRates({
    required String userName,
    required String originPostalCode,
    required String originCity,
    required String originState,
    required String destinationPostalCode,
    required String destinationCity,
    required String destinationState,
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
        destinationPostalCode: destinationPostalCode,
        destinationCity: destinationCity,
        destinationState: destinationState,
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
    final results = await Future.wait(futures);

    // Convertir a Map
    return Map.fromEntries(results);
  }

  ShippingRateRequest _buildRequest({
    required String originPostalCode,
    required String originCity,
    required String originState,
    required String destinationPostalCode,
    required String destinationCity,
    required String destinationState,
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
      ),
      destination: Destination(
        postalCode: destinationPostalCode,
        city: destinationCity,
        state: destinationState,
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
