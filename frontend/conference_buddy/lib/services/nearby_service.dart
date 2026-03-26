import 'api_service.dart';

class NearbyService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getNearbyCount(String conferenceId, {double? radiusKm}) async {
    final queryParams = <String, String>{'conferenceId': conferenceId};
    if (radiusKm != null) {
      queryParams['radiusKm'] = radiusKm.toString();
    }
    return await _api.get('/nearby/count', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> getNearbyUsers(String conferenceId, {double? radiusKm}) async {
    final queryParams = <String, String>{'conferenceId': conferenceId};
    if (radiusKm != null) {
      queryParams['radiusKm'] = radiusKm.toString();
    }
    return await _api.get('/nearby/users', queryParams: queryParams);
  }
}