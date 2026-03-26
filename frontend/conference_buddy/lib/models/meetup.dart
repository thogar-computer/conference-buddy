class MeetupParticipant {
  final String userId;
  final String fullName;
  final String status;
  final DateTime? respondedAt;

  MeetupParticipant({
    required this.userId,
    required this.fullName,
    required this.status,
    this.respondedAt,
  });

  factory MeetupParticipant.fromJson(Map<String, dynamic> json) {
    return MeetupParticipant(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      status: json['status'] ?? 'pending',
      respondedAt: json['responded_at'] != null 
          ? DateTime.parse(json['responded_at']) 
          : null,
    );
  }
}

class Meetup {
  final String id;
  final String creatorId;
  final String conferenceId;
  final String? venueName;
  final String? venueAddress;
  final double? venueLat;
  final double? venueLon;
  final String status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? conferenceName;
  final String? creatorName;
  final List<MeetupParticipant>? participants;

  Meetup({
    required this.id,
    required this.creatorId,
    required this.conferenceId,
    this.venueName,
    this.venueAddress,
    this.venueLat,
    this.venueLon,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.conferenceName,
    this.creatorName,
    this.participants,
  });

  factory Meetup.fromJson(Map<String, dynamic> json) {
    return Meetup(
      id: json['id'] ?? '',
      creatorId: json['creator_id'] ?? '',
      conferenceId: json['conference_id'] ?? '',
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      venueLat: json['venue_lat']?.toDouble(),
      venueLon: json['venue_lon']?.toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.parse(json['confirmed_at']) 
          : null,
      conferenceName: json['conference_name'],
      creatorName: json['creator_name'],
      participants: json['participants'] != null 
          ? (json['participants'] as List)
              .map((p) => MeetupParticipant.fromJson(p))
              .toList()
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
}