class User {
  final String id;
  final String email;
  final String fullName;
  final bool isAdmin;
  final DateTime createdAt;
  final List<String>? conferences;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.isAdmin = false,
    required this.createdAt,
    this.conferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      isAdmin: json['is_admin'] ?? json['isAdmin'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      conferences: json['conferences'] != null 
          ? List<String>.from(json['conferences']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
      'conferences': conferences,
    };
  }
}