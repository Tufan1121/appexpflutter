/// Información de un producto para cotización de envío
/// Agrupa la información necesaria para cotizar el envío de un producto específico
class ProductShippingInfo {
  /// Clave única del producto (producto1)
  final String productKey;
  
  /// Nombre del producto para mostrar
  final String productName;
  
  /// Largo del producto en centímetros
  final double largo;
  
  /// Ancho del producto en centímetros
  final double ancho;
  
  /// Alto estimado del producto en centímetros
  /// Si no se tiene, se puede estimar basado en el tipo de producto
  final double alto;
  
  /// Peso estimado por unidad en kilogramos
  final double peso;
  
  /// Cantidad de unidades de este producto
  final int cantidad;

  const ProductShippingInfo({
    required this.productKey,
    required this.productName,
    required this.largo,
    required this.ancho,
    required this.alto,
    required this.peso,
    required this.cantidad,
  });

  /// Construye un `ProductShippingInfo` a partir de las dimensiones crudas de
  /// un producto, aplicando la MISMA prioridad que la sesión de ventas
  /// (`lista_productos.dart` / `lista_productos_venta.dart`):
  ///
  /// - Largo/ancho: usa las dimensiones de PAQUETE (`largop`/`anchop` en cm) si
  ///   vienen; si no, convierte las del PRODUCTO (`largoM`/`anchoM` en metros) a
  ///   cm; si no hay nada, usa valores por defecto (30 / 20 cm).
  /// - Alto: `altop` en cm si viene; si no, 15 cm (tapete enrollado).
  /// - Peso: `peso` en kg si viene; si no, se estima por área (~3 kg/m²,
  ///   acotado entre 1.5 y 50 kg).
  factory ProductShippingInfo.fromDimensions({
    required String productKey,
    required String productName,
    double? largop,
    double? anchop,
    double? altop,
    double? peso,
    required double largoM,
    required double anchoM,
    int cantidad = 1,
  }) {
    final double largo = (largop != null && largop > 0)
        ? largop
        : (largoM > 0 ? largoM * 100 : 30.0);

    final double ancho = (anchop != null && anchop > 0)
        ? anchop
        : (anchoM > 0 ? anchoM * 100 : 20.0);

    final double alto = (altop != null && altop > 0) ? altop : 15.0;

    final double pesoFinal;
    if (peso != null && peso > 0) {
      pesoFinal = peso;
    } else {
      final area = largoM * anchoM;
      pesoFinal = area > 0 ? (area * 3.0).clamp(1.5, 50.0) : 2.0;
    }

    return ProductShippingInfo(
      productKey: productKey,
      productName: productName,
      largo: largo,
      ancho: ancho,
      alto: alto,
      peso: pesoFinal,
      cantidad: cantidad,
    );
  }

  /// Crea una copia con valores actualizados
  ProductShippingInfo copyWith({
    String? productKey,
    String? productName,
    double? largo,
    double? ancho,
    double? alto,
    double? peso,
    int? cantidad,
  }) {
    return ProductShippingInfo(
      productKey: productKey ?? this.productKey,
      productName: productName ?? this.productName,
      largo: largo ?? this.largo,
      ancho: ancho ?? this.ancho,
      alto: alto ?? this.alto,
      peso: peso ?? this.peso,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  @override
  String toString() {
    return 'ProductShippingInfo(key: $productKey, name: $productName, ${largo}x${ancho}x${alto}cm, ${peso}kg, qty: $cantidad)';
  }
}

/// Resultado de cotización por producto
class ProductShippingQuote {
  /// Información del producto original
  final ProductShippingInfo product;
  
  /// Costo de envío para este producto (ya con 30% de markup)
  final double shippingCost;
  
  /// Nombre del carrier seleccionado
  final String carrier;
  
  /// Descripción del servicio
  final String serviceDescription;
  
  /// Indica si hubo error en la cotización
  final bool hasError;
  
  /// Mensaje de error si aplica
  final String? errorMessage;

  const ProductShippingQuote({
    required this.product,
    required this.shippingCost,
    required this.carrier,
    required this.serviceDescription,
    this.hasError = false,
    this.errorMessage,
  });

  factory ProductShippingQuote.error({
    required ProductShippingInfo product,
    required String errorMessage,
  }) {
    return ProductShippingQuote(
      product: product,
      shippingCost: 0,
      carrier: '',
      serviceDescription: '',
      hasError: true,
      errorMessage: errorMessage,
    );
  }
}
