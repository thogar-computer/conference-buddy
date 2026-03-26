class Conference {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? createdAt;

  Conference({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.createdAt,
  });

  factory Conference.fromJson(Map<String, dynamic> json) {
    return Conference(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
    };
  }
}