// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserHiveAdapter extends TypeAdapter<UserHive> {
  @override
  final int typeId = 0;

  @override
  UserHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHive()
      ..userId = fields[0] as String
      ..name = fields[1] as String
      ..username = fields[2] as String
      ..password = fields[3] as String
      ..role = fields[4] as String
      ..email = fields[5] as String
      ..phone = fields[6] as String
      ..isActive = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, UserHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectHiveAdapter extends TypeAdapter<ProjectHive> {
  @override
  final int typeId = 1;

  @override
  ProjectHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectHive()
      ..projectId = fields[0] as String
      ..name = fields[1] as String
      ..location = fields[2] as String
      ..status = fields[3] as String
      ..physicalProgress = fields[4] as double
      ..financialProgress = fields[5] as double
      ..imageUrl = fields[6] as String
      ..description = fields[7] as String
      ..owner = fields[8] as String
      ..supervisor = fields[9] as String
      ..createdAt = fields[10] as String
      ..startDate = fields[11] as String
      ..endDate = fields[12] as String
      ..ownerDetail = fields[13] as String
      ..fundingSource = fields[14] as String
      ..isArchived = fields[15] as bool;
  }

  @override
  void write(BinaryWriter writer, ProjectHive obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.physicalProgress)
      ..writeByte(5)
      ..write(obj.financialProgress)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.owner)
      ..writeByte(9)
      ..write(obj.supervisor)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.endDate)
      ..writeByte(13)
      ..write(obj.ownerDetail)
      ..writeByte(14)
      ..write(obj.fundingSource)
      ..writeByte(15)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectMemberHiveAdapter extends TypeAdapter<ProjectMemberHive> {
  @override
  final int typeId = 2;

  @override
  ProjectMemberHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectMemberHive()
      ..projectId = fields[0] as String
      ..userId = fields[1] as String
      ..role = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, ProjectMemberHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectMemberHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectProgressHiveAdapter extends TypeAdapter<ProjectProgressHive> {
  @override
  final int typeId = 3;

  @override
  ProjectProgressHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectProgressHive()
      ..projectId = fields[0] as String
      ..physicalProgress = fields[1] as double
      ..financialProgress = fields[2] as double
      ..recordedAt = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, ProjectProgressHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.physicalProgress)
      ..writeByte(2)
      ..write(obj.financialProgress)
      ..writeByte(3)
      ..write(obj.recordedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectProgressHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentVersionHiveAdapter extends TypeAdapter<DocumentVersionHive> {
  @override
  final int typeId = 4;

  @override
  DocumentVersionHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentVersionHive()
      ..versionId = fields[0] as String
      ..name = fields[1] as String
      ..fileUrl = fields[2] as String
      ..fileSize = fields[3] as String
      ..uploadedBy = fields[4] as String
      ..uploadedAt = fields[5] as String
      ..version = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, DocumentVersionHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.versionId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fileUrl)
      ..writeByte(3)
      ..write(obj.fileSize)
      ..writeByte(4)
      ..write(obj.uploadedBy)
      ..writeByte(5)
      ..write(obj.uploadedAt)
      ..writeByte(6)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentVersionHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentHiveAdapter extends TypeAdapter<DocumentHive> {
  @override
  final int typeId = 5;

  @override
  DocumentHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentHive()
      ..documentId = fields[0] as String
      ..projectId = fields[1] as String
      ..folderName = fields[2] as String
      ..name = fields[3] as String
      ..fileUrl = fields[4] as String
      ..fileSize = fields[5] as String
      ..uploadedBy = fields[6] as String
      ..uploadedAt = fields[7] as String
      ..version = fields[8] as int
      ..versions = (fields[9] as List).cast<DocumentVersionHive>();
  }

  @override
  void write(BinaryWriter writer, DocumentHive obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.documentId)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.folderName)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.fileUrl)
      ..writeByte(5)
      ..write(obj.fileSize)
      ..writeByte(6)
      ..write(obj.uploadedBy)
      ..writeByte(7)
      ..write(obj.uploadedAt)
      ..writeByte(8)
      ..write(obj.version)
      ..writeByte(9)
      ..write(obj.versions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportHistoryHiveAdapter extends TypeAdapter<ReportHistoryHive> {
  @override
  final int typeId = 6;

  @override
  ReportHistoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportHistoryHive()
      ..date = fields[0] as String
      ..user = fields[1] as String
      ..action = fields[2] as String
      ..details = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, ReportHistoryHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(3)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportHistoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContractorReportHiveAdapter extends TypeAdapter<ContractorReportHive> {
  @override
  final int typeId = 7;

  @override
  ContractorReportHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContractorReportHive()
      ..reportId = fields[0] as String
      ..projectId = fields[1] as String
      ..date = fields[2] as String
      ..time = fields[3] as String
      ..weather = fields[4] as String
      ..location = fields[5] as String
      ..todayProgress = fields[6] as double
      ..tasksDone = fields[7] as String
      ..materialsUsed = fields[8] as String
      ..toolsUsed = fields[9] as String
      ..workersCount = fields[10] as String
      ..obstacles = fields[11] as String
      ..solutions = fields[12] as String
      ..notes = fields[13] as String
      ..photos = (fields[14] as List).cast<String>()
      ..attachments = (fields[15] as List).cast<String>()
      ..status = fields[16] as String
      ..reviewerName = fields[17] as String
      ..verificationDate = fields[18] as String
      ..revisionNotes = fields[19] as String
      ..changeHistory = (fields[20] as List).cast<ReportHistoryHive>();
  }

  @override
  void write(BinaryWriter writer, ContractorReportHive obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.weather)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.todayProgress)
      ..writeByte(7)
      ..write(obj.tasksDone)
      ..writeByte(8)
      ..write(obj.materialsUsed)
      ..writeByte(9)
      ..write(obj.toolsUsed)
      ..writeByte(10)
      ..write(obj.workersCount)
      ..writeByte(11)
      ..write(obj.obstacles)
      ..writeByte(12)
      ..write(obj.solutions)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.photos)
      ..writeByte(15)
      ..write(obj.attachments)
      ..writeByte(16)
      ..write(obj.status)
      ..writeByte(17)
      ..write(obj.reviewerName)
      ..writeByte(18)
      ..write(obj.verificationDate)
      ..writeByte(19)
      ..write(obj.revisionNotes)
      ..writeByte(20)
      ..write(obj.changeHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractorReportHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SupervisorReportHiveAdapter extends TypeAdapter<SupervisorReportHive> {
  @override
  final int typeId = 8;

  @override
  SupervisorReportHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupervisorReportHive()
      ..reportId = fields[0] as String
      ..projectId = fields[1] as String
      ..date = fields[2] as String
      ..time = fields[3] as String
      ..supervisorName = fields[4] as String
      ..location = fields[5] as String
      ..weather = fields[6] as String
      ..findings = fields[7] as String
      ..fieldConditions = fields[8] as String
      ..instructions = fields[9] as String
      ..recommendations = fields[10] as String
      ..notes = fields[11] as String
      ..photos = (fields[12] as List).cast<String>()
      ..attachments = (fields[13] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, SupervisorReportHive obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.supervisorName)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.weather)
      ..writeByte(7)
      ..write(obj.findings)
      ..writeByte(8)
      ..write(obj.fieldConditions)
      ..writeByte(9)
      ..write(obj.instructions)
      ..writeByte(10)
      ..write(obj.recommendations)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.photos)
      ..writeByte(13)
      ..write(obj.attachments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupervisorReportHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimelineHiveAdapter extends TypeAdapter<TimelineHive> {
  @override
  final int typeId = 9;

  @override
  TimelineHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimelineHive()
      ..timelineId = fields[0] as String
      ..projectId = fields[1] as String
      ..title = fields[2] as String
      ..description = fields[3] as String
      ..user = fields[4] as String
      ..role = fields[5] as String
      ..icon = fields[6] as String
      ..createdAt = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, TimelineHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.timelineId)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.user)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationHiveAdapter extends TypeAdapter<NotificationHive> {
  @override
  final int typeId = 10;

  @override
  NotificationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationHive()
      ..notificationId = fields[0] as String
      ..title = fields[1] as String
      ..message = fields[2] as String
      ..type = fields[3] as String
      ..isRead = fields[4] as bool
      ..createdAt = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, NotificationHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.notificationId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isRead)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhotoDocumentationHiveAdapter
    extends TypeAdapter<PhotoDocumentationHive> {
  @override
  final int typeId = 11;

  @override
  PhotoDocumentationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoDocumentationHive()
      ..projectId = fields[0] as String
      ..reportId = fields[1] as String
      ..photoUrl = fields[2] as String
      ..description = fields[3] as String
      ..uploadedAt = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, PhotoDocumentationHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.reportId)
      ..writeByte(2)
      ..write(obj.photoUrl)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoDocumentationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityHistoryHiveAdapter extends TypeAdapter<ActivityHistoryHive> {
  @override
  final int typeId = 12;

  @override
  ActivityHistoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityHistoryHive()
      ..userId = fields[0] as String
      ..action = fields[1] as String
      ..details = fields[2] as String
      ..timestamp = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, ActivityHistoryHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityHistoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
