import 'package:hive/hive.dart';

part 'hive_models.g.dart';

@HiveType(typeId: 0)
class UserHive extends HiveObject {
  @HiveField(0)
  late String userId;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late String username;
  @HiveField(3)
  late String password;
  @HiveField(4)
  late String role;
  @HiveField(5)
  late String email;
  @HiveField(6)
  late String phone;
  @HiveField(7)
  late bool isActive;
}

@HiveType(typeId: 1)
class ProjectHive extends HiveObject {
  @HiveField(0)
  late String projectId;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late String location;
  @HiveField(3)
  late String status; // "Progres" | "Selesai"
  @HiveField(4)
  late double physicalProgress;
  @HiveField(5)
  late double financialProgress;
  @HiveField(6)
  late String imageUrl;
  @HiveField(7)
  late String description;
  @HiveField(8)
  late String owner;
  @HiveField(9)
  late String supervisor;
  @HiveField(10)
  late String createdAt;
  @HiveField(11)
  late String startDate;
  @HiveField(12)
  late String endDate;
  @HiveField(13)
  late String ownerDetail;
  @HiveField(14)
  late String fundingSource;
  @HiveField(15)
  late bool isArchived;
}

@HiveType(typeId: 2)
class ProjectMemberHive extends HiveObject {
  @HiveField(0)
  late String projectId;
  @HiveField(1)
  late String userId;
  @HiveField(2)
  late String role;
}

@HiveType(typeId: 3)
class ProjectProgressHive extends HiveObject {
  @HiveField(0)
  late String projectId;
  @HiveField(1)
  late double physicalProgress;
  @HiveField(2)
  late double financialProgress;
  @HiveField(3)
  late String recordedAt;
}

@HiveType(typeId: 4)
class DocumentVersionHive extends HiveObject {
  @HiveField(0)
  late String versionId;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late String fileUrl;
  @HiveField(3)
  late String fileSize;
  @HiveField(4)
  late String uploadedBy;
  @HiveField(5)
  late String uploadedAt;
  @HiveField(6)
  late int version;
}

@HiveType(typeId: 5)
class DocumentHive extends HiveObject {
  @HiveField(0)
  late String documentId;
  @HiveField(1)
  late String projectId;
  @HiveField(2)
  late String folderName;
  @HiveField(3)
  late String name;
  @HiveField(4)
  late String fileUrl;
  @HiveField(5)
  late String fileSize;
  @HiveField(6)
  late String uploadedBy;
  @HiveField(7)
  late String uploadedAt;
  @HiveField(8)
  late int version;
  @HiveField(9)
  late List<DocumentVersionHive> versions;
}

@HiveType(typeId: 6)
class ReportHistoryHive extends HiveObject {
  @HiveField(0)
  late String date;
  @HiveField(1)
  late String user;
  @HiveField(2)
  late String action;
  @HiveField(3)
  late String details;
}

@HiveType(typeId: 7)
class ContractorReportHive extends HiveObject {
  @HiveField(0)
  late String reportId;
  @HiveField(1)
  late String projectId;
  @HiveField(2)
  late String date;
  @HiveField(3)
  late String time;
  @HiveField(4)
  late String weather;
  @HiveField(5)
  late String location;
  @HiveField(6)
  late double todayProgress;
  @HiveField(7)
  late String tasksDone;
  @HiveField(8)
  late String materialsUsed;
  @HiveField(9)
  late String toolsUsed;
  @HiveField(10)
  late String workersCount;
  @HiveField(11)
  late String obstacles;
  @HiveField(12)
  late String solutions;
  @HiveField(13)
  late String notes;
  @HiveField(14)
  late List<String> photos;
  @HiveField(15)
  late List<String> attachments;
  @HiveField(16)
  late String status; 
  @HiveField(17)
  late String reviewerName;
  @HiveField(18)
  late String verificationDate;
  @HiveField(19)
  late String revisionNotes;
  @HiveField(20)
  late List<ReportHistoryHive> changeHistory;
}

@HiveType(typeId: 8)
class SupervisorReportHive extends HiveObject {
  @HiveField(0)
  late String reportId;
  @HiveField(1)
  late String projectId;
  @HiveField(2)
  late String date;
  @HiveField(3)
  late String time;
  @HiveField(4)
  late String supervisorName;
  @HiveField(5)
  late String location;
  @HiveField(6)
  late String weather;
  @HiveField(7)
  late String findings;
  @HiveField(8)
  late String fieldConditions;
  @HiveField(9)
  late String instructions;
  @HiveField(10)
  late String recommendations;
  @HiveField(11)
  late String notes;
  @HiveField(12)
  late List<String> photos;
  @HiveField(13)
  late List<String> attachments;
}

@HiveType(typeId: 9)
class TimelineHive extends HiveObject {
  @HiveField(0)
  late String timelineId;
  @HiveField(1)
  late String projectId; 
  @HiveField(2)
  late String title;
  @HiveField(3)
  late String description;
  @HiveField(4)
  late String user;
  @HiveField(5)
  late String role;
  @HiveField(6)
  late String icon;
  @HiveField(7)
  late String createdAt;
}

@HiveType(typeId: 10)
class NotificationHive extends HiveObject {
  @HiveField(0)
  late String notificationId;
  @HiveField(1)
  late String title;
  @HiveField(2)
  late String message;
  @HiveField(3)
  late String type;
  @HiveField(4)
  late bool isRead;
  @HiveField(5)
  late String createdAt;
}

@HiveType(typeId: 11)
class PhotoDocumentationHive extends HiveObject {
  @HiveField(0)
  late String projectId;
  @HiveField(1)
  late String reportId;
  @HiveField(2)
  late String photoUrl;
  @HiveField(3)
  late String description;
  @HiveField(4)
  late String uploadedAt;
}

@HiveType(typeId: 12)
class ActivityHistoryHive extends HiveObject {
  @HiveField(0)
  late String userId;
  @HiveField(1)
  late String action;
  @HiveField(2)
  late String details;
  @HiveField(3)
  late String timestamp;
}
