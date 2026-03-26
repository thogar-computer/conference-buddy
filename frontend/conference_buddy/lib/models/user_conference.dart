import 'conference.dart';

class UserConference {
  final String userId;
  final String conferenceId;
  final String? hotelName;
  final String? hotelAddress;
  final double? hotelLat;
  final double? hotelLon;
  final String? conferenceName;
  final DateTime? startDate;
  final DateTime? endDate;

  UserConference({
    required this.userId,
    required this.conferenceId,
    this.hotelName,
    this.hotelAddress,
    this.hotelLat,
    this.hotelLon,
    this.conferenceName,
    this.startDate,
    this.endDate,
  });

  factory UserConference.fromJson(Map<String, dynamic> json) {
    return UserConference(
      userId: json['user_id'] ?? '',
      conferenceId: json['conference_id'] ?? '',
      hotelName: json['hotel_name'],
      hotelAddress: json['hotel_address'],
      hotelLat: json['hotel_lat']?.toDouble(),
      hotelLon: json['hotel_lon']?.toDouble(),
      conferenceName: json['conference_name'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  bool get hasLocation => hotelLat != null && hotelLon != null;
}