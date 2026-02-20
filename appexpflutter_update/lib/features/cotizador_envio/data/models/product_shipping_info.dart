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
