class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'Approval' | 'Revisi' | 'Laporan Baru' | 'Dokumen Baru' | 'Progress Berubah' | 'Timeline Baru'
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt,
      };

  NotificationModel copyWith({
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
