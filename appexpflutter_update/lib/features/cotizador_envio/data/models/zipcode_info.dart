/// Modelo para la respuesta del API de geocodes de envia.com
class ZipcodeInfo {
  final String zipCode;
  final ZipcodeCountry country;
  final ZipcodeState state;
  final String locality;
  final List<String> suburbs;
  final ZipcodeCoordinates? coordinates;
  final ZipcodeRegions? regions;

  ZipcodeInfo({
    required this.zipCode,
    required this.country,
    required this.state,
    required this.locality,
    this.suburbs = const [],
    this.coordinates,
    this.regions,
  });

  factory ZipcodeInfo.fromJson(Map<String, dynamic> json) {
    return ZipcodeInfo(
      zipCode: json['zip_code']?.toString() ?? '',
      country: ZipcodeCountry.fromJson(json['country'] ?? {}),
      state: ZipcodeState.fromJson(json['state'] ?? {}),
      locality: json['locality']?.toString() ?? '',
      suburbs: (json['suburbs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      coordinates: json['coordinates'] != null
          ? ZipcodeCoordinates.fromJson(json['coordinates'])
          : null,
      regions:
          json['regions'] != null ? ZipcodeRegions.fromJson(json['regions']) : null,
    );
  }

  /// Obtiene el código de estado de 2 dígitos (ej: "EM" para Estado de México)
  String get stateCode2 => state.code2digit ?? state.name;

  /// Obtiene el código de estado de 3 dígitos (ej: "MEX" para Estado de México)
  String get stateCode3 => state.code3digit ?? state.name;
}

class ZipcodeCountry {
  final String name;
  final String code;

  ZipcodeCountry({
    required this.name,
    required this.code,
  });

  factory ZipcodeCountry.fromJson(Map<String, dynamic> json) {
    return ZipcodeCountry(
      name: json['name']?.toString() ?? 'México',
      code: json['code']?.toString() ?? 'MX',
    );
  }
}

class ZipcodeState {
  final String name;
  final String? isoCode;
  final String? code2digit;
  final String? code3digit;

  ZipcodeState({
    required this.name,
    this.isoCode,
    this.code2digit,
    this.code3digit,
  });

  factory ZipcodeState.fromJson(Map<String, dynamic> json) {
    final codeMap = json['code'] as Map<String, dynamic>?;
    return ZipcodeState(
      name: json['name']?.toString() ?? '',
      isoCode: json['iso_code']?.toString(),
      code2digit: codeMap?['2digit']?.toString(),
      code3digit: codeMap?['3digit']?.toString(),
    );
  }
}

class ZipcodeCoordinates {
  final String? latitude;
  final String? longitude;

  ZipcodeCoordinates({
    this.latitude,
    this.longitude,
  });

  factory ZipcodeCoordinates.fromJson(Map<String, dynamic> json) {
    return ZipcodeCoordinates(
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class ZipcodeRegions {
  final String? region1;
  final String? region2;
  final String? region3;
  final String? region4;

  ZipcodeRegions({
    this.region1,
    this.region2,
    this.region3,
    this.region4,
  });

  factory ZipcodeRegions.fromJson(Map<String, dynamic> json) {
    return ZipcodeRegions(
      region1: json['region_1']?.toString(),
      region2: json['region_2']?.toString(),
      region3: json['region_3']?.toString(),
      region4: json['region_4']?.toString(),
    );
  }
}
