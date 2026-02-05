class ShippingRateResponse {
  final String meta;
  final List<ShippingRate> data;
  final String? error;

  ShippingRateResponse({
    required this.meta,
    required this.data,
    this.error,
  });

  factory ShippingRateResponse.fromJson(Map<String, dynamic> json) {
    return ShippingRateResponse(
      meta: json['meta'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ShippingRate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory ShippingRateResponse.error(String message) {
    return ShippingRateResponse(
      meta: 'error',
      data: [],
      error: message,
    );
  }
}

class ShippingRate {
  final int carrierId;
  final String carrier;
  final String carrierDescription;
  final int serviceId;
  final String service;
  final String serviceDescription;
  final String deliveryEstimate;
  final DeliveryDate? deliveryDate;
  final double totalPrice;
  final String currency;

  ShippingRate({
    required this.carrierId,
    required this.carrier,
    required this.carrierDescription,
    required this.serviceId,
    required this.service,
    required this.serviceDescription,
    required this.deliveryEstimate,
    this.deliveryDate,
    required this.totalPrice,
    required this.currency,
  });

  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    // Obtener el precio original y aplicar 30% de aumento con redondeo hacia arriba
    final double originalPrice = (json['totalPrice'] ?? 0).toDouble();
    final double priceWithMarkup = originalPrice * 1.30; // +30%
    final double roundedPrice = priceWithMarkup.ceilToDouble(); // Redondeo hacia arriba

    return ShippingRate(
      carrierId: json['carrierId'] ?? 0,
      carrier: json['carrier'] ?? '',
      carrierDescription: json['carrierDescription'] ?? '',
      serviceId: json['serviceId'] ?? 0,
      service: json['service'] ?? '',
      serviceDescription: json['serviceDescription'] ?? '',
      deliveryEstimate: json['deliveryEstimate'] ?? '',
      deliveryDate: json['deliveryDate'] != null
          ? DeliveryDate.fromJson(json['deliveryDate'])
          : null,
      totalPrice: roundedPrice,
      currency: json['currency'] ?? 'MXN',
    );
  }
}

class DeliveryDate {
  final String date;
  final int dateDifference;
  final String timeUnit;
  final String time;

  DeliveryDate({
    required this.date,
    required this.dateDifference,
    required this.timeUnit,
    required this.time,
  });

  factory DeliveryDate.fromJson(Map<String, dynamic> json) {
    return DeliveryDate(
      date: json['date'] ?? '',
      dateDifference: json['dateDifference'] ?? 0,
      timeUnit: json['timeUnit'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
