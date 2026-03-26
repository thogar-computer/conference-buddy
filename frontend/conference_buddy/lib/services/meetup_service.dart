import '../models/meetup.dart';
import 'api_service.dart';

class MeetupService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> createMeetup({
    required String conferenceId,
    double? radiusKm,
  }) async {
    return await _api.post('/meetups', {
      'conferenceId': conferenceId,
      'radiusKm': radiusKm,
    });
  }

  Future<List<Meetup>> getMeetups() async {
    final response = await _api.get('/meetups');
    if (response is List) {
      return response.map((json) => Meetup.fromJson(json)).toList();
    }
    return [];
  }

  Future<Meetup> getMeetupById(String meetupId) async {
    final response = await _api.get('/meetups/$meetupId');
    return Meetup.fromJson(response);
  }

  Future<Map<String, dynamic>> respondToMeetup(String meetupId, bool accept) async {
    return await _api.post('/meetups/$meetupId/respond', {
      'accept': accept,
    });
  }
}