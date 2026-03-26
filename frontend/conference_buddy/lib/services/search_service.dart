import 'api_service.dart';

class LocationResult {
  final String name;
  final String fullAddress;
  final double lat;
  final double lon;
  final String? type;

  LocationResult({
    required this.name,
    required this.fullAddress,
    required this.lat,
    required this.lon,
    this.type,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      name: json['name'] ?? '',
      fullAddress: json['fullAddress'] ?? json['address'] ?? '',
      lat: (json['lat'] ?? json['latitude'] ?? 0).toDouble(),
      lon: (json['lng'] ?? json['lon'] ?? json['longitude'] ?? 0).toDouble(),
      type: json['type'],
    );
  }
}

class SearchService {
  final ApiService _api = ApiService();

  Future<List<LocationResult>> searchLocations(String query) async {
    final response = await _api.get('/search/locations', queryParams: {'query': query});
    if (response is List) {
      return response.map((json) => LocationResult.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<LocationResult>> searchHotels(String query) async {
    final response = await _api.get('/search/hotels', queryParams: {'query': query});
    if (response is List) {
      return response.map((json) => LocationResult.fromJson(json)).toList();
    }
    return [];
  }
}