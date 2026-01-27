class ShippingRateRequest {
  final Origin origin;
  final Destination destination;
  final List<Package> packages;
  final Shipment shipment;
  final Settings settings;

  ShippingRateRequest({
    required this.origin,
    required this.destination,
    required this.packages,
    required this.shipment,
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'origin': origin.toJson(),
        'destination': destination.toJson(),
        'packages': packages.map((p) => p.toJson()).toList(),
        'shipment': shipment.toJson(),
        'settings': settings.toJson(),
      };
}

class Origin {
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String district;

  Origin({
    this.city = '',
    this.state = '',
    this.country = 'MX',
    required this.postalCode,
    this.district = '',
  });

  Map<String, dynamic> toJson() => {
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'district': district,
      };
}

class Destination {
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String district;

  Destination({
    this.city = '',
    this.state = '',
    this.country = 'MX',
    required this.postalCode,
    this.district = '',
  });

  Map<String, dynamic> toJson() => {
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'district': district,
      };
}

class Package {
  final String content;
  final int amount;
  final String type;
  final Dimensions dimensions;
  final double weight;
  final int insurance;
  final int declaredValue;
  final String weightUnit;
  final String lengthUnit;

  Package({
    this.content = 'Alfombras',
    this.amount = 1,
    this.type = 'box',
    required this.dimensions,
    required this.weight,
    this.insurance = 0,
    this.declaredValue = 0,
    this.weightUnit = 'KG',
    this.lengthUnit = 'CM',
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'amount': amount,
        'type': type,
        'dimensions': dimensions.toJson(),
        'weight': weight,
        'insurance': insurance,
        'declaredValue': declaredValue,
        'weightUnit': weightUnit,
        'lengthUnit': lengthUnit,
      };
}

class Dimensions {
  final double length;
  final double width;
  final double height;

  Dimensions({
    required this.length,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
        'length': length,
        'width': width,
        'height': height,
      };
}

class Shipment {
  final String carrier;
  final int type;

  Shipment({
    required this.carrier,
    this.type = 1,
  });

  Map<String, dynamic> toJson() => {
        'carrier': carrier,
        'type': type,
      };
}

class Settings {
  final String currency;

  Settings({
    this.currency = 'MXN',
  });

  Map<String, dynamic> toJson() => {
        'currency': currency,
      };
}
