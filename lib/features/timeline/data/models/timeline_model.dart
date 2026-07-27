class TimelineModel {
  final String id;
  final String title;
  final String description;
  final String user;
  final String role;
  final String icon;
  final String createdAt;

  const TimelineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.user,
    required this.role,
    required this.icon,
    required this.createdAt,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    return TimelineModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      user: json['user'] as String,
      role: json['role'] as String,
      icon: json['icon'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'user': user,
        'role': role,
        'icon': icon,
        'createdAt': createdAt,
      };
}
