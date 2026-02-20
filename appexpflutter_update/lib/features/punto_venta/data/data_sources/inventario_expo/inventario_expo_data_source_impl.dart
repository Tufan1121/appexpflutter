import 'package:api_client/api_client.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/inventario_expo/inventario_expo_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/producto_expo_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InventarioExpoVentaDataSourceImpl
    implements InventarioExpoVentaDataSource {
  final DioClient _dioClient;
  final storage = const FlutterSecureStorage();

  InventarioExpoVentaDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<ProductoExpoModel>> getProductosExpo(
      Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/busquedaExpo/',
          queryParameters: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final List<dynamic> jsonList = result.data;
      
      // DEBUG: Log para verificar dimensiones del paquete
      print('═══════════════════════════════════════════════════════════════');
      print('📦 [PUNTO VENTA] /busquedaExpo/ - Datos recibidos:');
      print('   Cantidad de productos: ${jsonList.length}');
      if (jsonList.isNotEmpty) {
        final firstProduct = jsonList[0];
        print('   Primer producto: ${firstProduct['producto1']}');
        print('   Dimensiones de paquete:');
        print('      largop: ${firstProduct['largop']}');
        print('      anchop: ${firstProduct['anchop']}');
        print('      altop: ${firstProduct['altop']}');
        print('      peso: ${firstProduct['peso']}');
      }
      print('═══════════════════════════════════════════════════════════════');
      
      final productosBodega = jsonList
          .map(
            (json) => ProductoExpoModel.fromJson(json),
          )
          .toList();
      return productosBodega;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ProductoExpoModel> getProductoExpo(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'accessToken');
    try {
      final result = await _dioClient.get('/buscaSpock/',
          queryParameters: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final jsonList = result.data;
      if (jsonList.isNotEmpty) {
        final reducedJson = jsonList as Map<String, dynamic>;
        
        // DEBUG: Log para verificar qué devuelve /buscaSpock/
        print('═══════════════════════════════════════════════════════════════');
        print('📦 [PUNTO VENTA] /buscaSpock/ - Datos ORIGINALES (reducedJson):');
        print('   producto: ${reducedJson['producto']}');
        print('   Dimensiones en JSON original:');
        print('      largop: ${reducedJson['largop']}');
        print('      anchop: ${reducedJson['anchop']}');
        print('      altop: ${reducedJson['altop']}');
        print('      peso: ${reducedJson['peso']}');
        print('═══════════════════════════════════════════════════════════════');
        
        final fullJson = convertReducedJsonToFullJson(reducedJson);
        
        // DEBUG: Log después de la conversión
        print('═══════════════════════════════════════════════════════════════');
        print('📦 [PUNTO VENTA] /buscaSpock/ - Datos DESPUÉS de convertReducedJsonToFullJson:');
        print('   producto1: ${fullJson['producto1']}');
        print('   Dimensiones en fullJson:');
        print('      largop: ${fullJson['largop']}');
        print('      anchop: ${fullJson['anchop']}');
        print('      altop: ${fullJson['altop']}');
        print('      peso: ${fullJson['peso']}');
        print('═══════════════════════════════════════════════════════════════');
        
        final productoExpo = ProductoExpoModel.fromJson(fullJson);
        
        // DEBUG: Log del modelo final
        print('═══════════════════════════════════════════════════════════════');
        print('📦 [PUNTO VENTA] /buscaSpock/ - ProductoExpoModel FINAL:');
        print('   producto1: ${productoExpo.producto1}');
        print('   Dimensiones en modelo:');
        print('      largop: ${productoExpo.largop}');
        print('      anchop: ${productoExpo.anchop}');
        print('      altop: ${productoExpo.altop}');
        print('      pesoEnvio: ${productoExpo.pesoEnvio}');
        print('═══════════════════════════════════════════════════════════════');
        
        return productoExpo;
      } else {
        throw Exception('No data found');
      }
    } catch (_) {
      rethrow;
    }
  }
}
