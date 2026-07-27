import 'dart:convert';

class ReportHistory {
  final String date;
  final String user;
  final String action; // e.g. "Dibuat", "Revisi", "Kirim Ulang"
  final String details;

  const ReportHistory({
    required this.date,
    required this.user,
    required this.action,
    required this.details,
  });

  factory ReportHistory.fromJson(Map<String, dynamic> json) {
    return ReportHistory(
      date: json['date'] as String,
      user: json['user'] as String,
      action: json['action'] as String,
      details: json['details'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'user': user,
        'action': action,
        'details': details,
      };
}

class ContractorReportModel {
  final String id;
  final String projectId;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String weather;
  final String location;
  final double todayProgress; // e.g. 0.05 (means 5%)
  final String tasksDone;
  final String materialsUsed;
  final String toolsUsed;
  final String workersCount;
  final String obstacles;
  final String solutions;
  final String notes;
  final List<String> photos;
  final List<String> attachments;
  final String status; // 'MENUNGGU VERIFIKASI' | 'DISETUJUI' | 'DITOLAK'
  final String reviewerName;
  final String verificationDate;
  final String revisionNotes;
  final List<ReportHistory> changeHistory;

  const ContractorReportModel({
    required this.id,
    required this.projectId,
    required this.date,
    required this.time,
    required this.weather,
    required this.location,
    required this.todayProgress,
    required this.tasksDone,
    required this.materialsUsed,
    required this.toolsUsed,
    required this.workersCount,
    required this.obstacles,
    required this.solutions,
    required this.notes,
    required this.photos,
    required this.attachments,
    this.status = 'MENUNGGU VERIFIKASI',
    this.reviewerName = '',
    this.verificationDate = '',
    this.revisionNotes = '',
    this.changeHistory = const [],
  });

  factory ContractorReportModel.fromJson(Map<String, dynamic> json) {
    return ContractorReportModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      weather: json['weather'] as String,
      location: json['location'] as String,
      todayProgress: (json['todayProgress'] as num).toDouble(),
      tasksDone: json['tasksDone'] as String,
      materialsUsed: json['materialsUsed'] as String,
      toolsUsed: json['toolsUsed'] as String,
      workersCount: json['workersCount'] as String,
      obstacles: json['obstacles'] as String,
      solutions: json['solutions'] as String,
      notes: json['notes'] as String,
      photos: List<String>.from(json['photos'] as List? ?? []),
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      status: json['status'] as String? ?? 'MENUNGGU VERIFIKASI',
      reviewerName: json['reviewerName'] as String? ?? '',
      verificationDate: json['verificationDate'] as String? ?? '',
      revisionNotes: json['revisionNotes'] as String? ?? '',
      changeHistory: (json['changeHistory'] as List? ?? [])
          .map((h) => ReportHistory.fromJson(Map<String, dynamic>.from(h)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'date': date,
        'time': time,
        'weather': weather,
        'location': location,
        'todayProgress': todayProgress,
        'tasksDone': tasksDone,
        'materialsUsed': materialsUsed,
        'toolsUsed': toolsUsed,
        'workersCount': workersCount,
        'obstacles': obstacles,
        'solutions': solutions,
        'notes': notes,
        'photos': photos,
        'attachments': attachments,
        'status': status,
        'reviewerName': reviewerName,
        'verificationDate': verificationDate,
        'revisionNotes': revisionNotes,
        'changeHistory': changeHistory.map((h) => h.toJson()).toList(),
      };

  ContractorReportModel copyWith({
    String? status,
    String? reviewerName,
    String? verificationDate,
    String? revisionNotes,
    List<ReportHistory>? changeHistory,
    double? todayProgress,
    String? tasksDone,
    String? materialsUsed,
    String? toolsUsed,
    String? workersCount,
    String? obstacles,
    String? solutions,
    String? notes,
    String? weather,
    List<String>? photos,
    List<String>? attachments,
  }) {
    return ContractorReportModel(
      id: id,
      projectId: projectId,
      date: date,
      time: time,
      weather: weather ?? this.weather,
      location: location,
      todayProgress: todayProgress ?? this.todayProgress,
      tasksDone: tasksDone ?? this.tasksDone,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      toolsUsed: toolsUsed ?? this.toolsUsed,
      workersCount: workersCount ?? this.workersCount,
      obstacles: obstacles ?? this.obstacles,
      solutions: solutions ?? this.solutions,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      reviewerName: reviewerName ?? this.reviewerName,
      verificationDate: verificationDate ?? this.verificationDate,
      revisionNotes: revisionNotes ?? this.revisionNotes,
      changeHistory: changeHistory ?? this.changeHistory,
    );
  }
}

class SupervisorReportModel {
  final String id;
  final String projectId;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String supervisorName;
  final String location;
  final String weather;
  final String findings;
  final String fieldConditions;
  final String instructions;
  final String recommendations;
  final String notes;
  final List<String> photos;
  final List<String> attachments;

  const SupervisorReportModel({
    required this.id,
    required this.projectId,
    required this.date,
    required this.time,
    required this.supervisorName,
    required this.location,
    required this.weather,
    required this.findings,
    required this.fieldConditions,
    required this.instructions,
    required this.recommendations,
    required this.notes,
    required this.photos,
    required this.attachments,
  });

  factory SupervisorReportModel.fromJson(Map<String, dynamic> json) {
    return SupervisorReportModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      supervisorName: json['supervisorName'] as String,
      location: json['location'] as String,
      weather: json['weather'] as String,
      findings: json['findings'] as String,
      fieldConditions: json['fieldConditions'] as String,
      instructions: json['instructions'] as String,
      recommendations: json['recommendations'] as String,
      notes: json['notes'] as String,
      photos: List<String>.from(json['photos'] as List? ?? []),
      attachments: List<String>.from(json['attachments'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'date': date,
        'time': time,
        'supervisorName': supervisorName,
        'location': location,
        'weather': weather,
        'findings': findings,
        'fieldConditions': fieldConditions,
        'instructions': instructions,
        'recommendations': recommendations,
        'notes': notes,
        'photos': photos,
        'attachments': attachments,
      };
}
