import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class UserIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  late String name;
  late String username;
  late String password;
  late String role;
  late String email;
  late String phone;
  late bool isActive;
}

@collection
class ProjectIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String projectId;

  late String name;
  late String location;
  late String status; // "Progres" | "Selesai"
  late double physicalProgress;
  late double financialProgress;
  late String imageUrl;
  late String description;
  late String owner;
  late String supervisor;
  late String createdAt;
  late String startDate;
  late String endDate;
  late String ownerDetail;
  late String fundingSource;

  @Index()
  late bool isArchived;
}

@collection
class ProjectMemberIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late String projectId;

  @Index()
  late String userId;

  late String role;
}

@collection
class ProjectProgressIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late String projectId;

  late double physicalProgress;
  late double financialProgress;
  late String recordedAt;
}

@embedded
class DocumentVersionIsar {
  late String versionId;
  late String name;
  late String fileUrl;
  late String fileSize;
  late String uploadedBy;
  late String uploadedAt;
  late int version;
}

@collection
class DocumentIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String documentId;

  @Index()
  late String projectId;

  late String folderName;
  late String name;
  late String fileUrl;
  late String fileSize;
  late String uploadedBy;
  late String uploadedAt;
  late int version;

  late List<DocumentVersionIsar> versions;
}

@embedded
class ReportHistoryIsar {
  late String date;
  late String user;
  late String action;
  late String details;
}

@collection
class ContractorReportIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String reportId;

  @Index()
  late String projectId;

  late String date;
  late String time;
  late String weather;
  late String location;
  late double todayProgress;
  late String tasksDone;
  late String materialsUsed;
  late String toolsUsed;
  late String workersCount;
  late String obstacles;
  late String solutions;
  late String notes;
  late List<String> photos;
  late List<String> attachments;
  late String status; // 'MENUNGGU VERIFIKASI' | 'DISETUJUI' | 'DITOLAK'
  late String reviewerName;
  late String verificationDate;
  late String revisionNotes;

  late List<ReportHistoryIsar> changeHistory;
}

@collection
class SupervisorReportIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String reportId;

  @Index()
  late String projectId;

  late String date;
  late String time;
  late String supervisorName;
  late String location;
  late String weather;
  late String findings;
  late String fieldConditions;
  late String instructions;
  late String recommendations;
  late String notes;
  late List<String> photos;
  late List<String> attachments;
}

@collection
class TimelineIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String timelineId;

  @Index()
  late String projectId; // can be empty string for global timeline

  late String title;
  late String description;
  late String user;
  late String role;
  late String icon;
  late String createdAt;
}

@collection
class NotificationIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String notificationId;

  late String title;
  late String message;
  late String type;
  late bool isRead;
  late String createdAt;
}

@collection
class PhotoDocumentationIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late String projectId;

  late String reportId;
  late String photoUrl;
  late String description;
  late String uploadedAt;
}

@collection
class ActivityHistoryIsar {
  Id id = Isar.autoIncrement;

  late String userId;
  late String action;
  late String details;
  late String timestamp;
}
