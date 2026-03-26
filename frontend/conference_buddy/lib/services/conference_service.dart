import '../models/conference.dart';
import '../models/user_conference.dart';
import 'api_service.dart';

class ConferenceService {
  final ApiService _api = ApiService();

  Future<List<Conference>> getConferences() async {
    final response = await _api.get('/conferences');
    if (response is List) {
      return response.map((json) => Conference.fromJson(json)).toList();
    }
    return [];
  }

  Future<Conference> getConferenceById(String id) async {
    final response = await _api.get('/conferences/$id');
    return Conference.fromJson(response);
  }

  Future<List<UserConference>> getUserConferences() async {
    final response = await _api.get('/user-conferences');
    if (response is List) {
      return response.map((json) => UserConference.fromJson(json)).toList();
    }
    return [];
  }

  Future<UserConference> registerForConference({
    required String conferenceId,
    required String hotelName,
    String? hotelAddress,
    required double hotelLat,
    required double hotelLon,
  }) async {
    final response = await _api.post('/user-conferences', {
      'conferenceId': conferenceId,
      'hotelName': hotelName,
      'hotelAddress': hotelAddress,
      'hotelLat': hotelLat,
      'hotelLon': hotelLon,
    });
    return UserConference.fromJson(response);
  }

  Future<UserConference> updateHotelLocation({
    required String conferenceId,
    required String hotelName,
    String? hotelAddress,
    required double hotelLat,
    required double hotelLon,
  }) async {
    final response = await _api.put('/user-conferences/$conferenceId', {
      'hotelName': hotelName,
      'hotelAddress': hotelAddress,
      'hotelLat': hotelLat,
      'hotelLon': hotelLon,
    });
    return UserConference.fromJson(response);
  }
}