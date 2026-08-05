import re

with open('lib/core/database/isar_database_service.dart', 'r') as f:
    content = f.read()

# Replace imports
content = content.replace("import 'package:isar/isar.dart';", "import 'package:hive_flutter/hive_flutter.dart';")
content = content.replace("import 'isar_models.dart';", "import 'hive_models.dart';")
content = re.sub(r"import 'package:path_provider/path_provider\.dart';\n?", "", content)
content = re.sub(r"import 'package:flutter/foundation\.dart';\n?", "", content)

# Rewrite class structure
new_class_top = """class HiveDatabaseService {
  static bool _isInitialized = false;

  static Future<void> initDb() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserHiveAdapter());
      Hive.registerAdapter(ProjectHiveAdapter());
      Hive.registerAdapter(ProjectMemberHiveAdapter());
      Hive.registerAdapter(ProjectProgressHiveAdapter());
      Hive.registerAdapter(DocumentVersionHiveAdapter());
      Hive.registerAdapter(DocumentHiveAdapter());
      Hive.registerAdapter(ReportHistoryHiveAdapter());
      Hive.registerAdapter(ContractorReportHiveAdapter());
      Hive.registerAdapter(SupervisorReportHiveAdapter());
      Hive.registerAdapter(TimelineHiveAdapter());
      Hive.registerAdapter(NotificationHiveAdapter());
      Hive.registerAdapter(PhotoDocumentationHiveAdapter());
      Hive.registerAdapter(ActivityHistoryHiveAdapter());
    }

    final userBox = await Hive.openBox<UserHive>('users');
    await Hive.openBox<ProjectHive>('projects');
    await Hive.openBox<ProjectMemberHive>('projectMembers');
    await Hive.openBox<ProjectProgressHive>('projectProgress');
    await Hive.openBox<DocumentHive>('documents');
    await Hive.openBox<ContractorReportHive>('contractorReports');
    await Hive.openBox<SupervisorReportHive>('supervisorReports');
    await Hive.openBox<TimelineHive>('timelines');
    await Hive.openBox<NotificationHive>('notifications');
    await Hive.openBox<PhotoDocumentationHive>('photoDocumentation');
    await Hive.openBox<ActivityHistoryHive>('activityHistory');

    final userCount = userBox.length;
    final hasKonsultan = userBox.values.any((u) => u.username == 'konsultan');
    final String correctHash = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
    
    bool needsSeeding = userCount == 0 || !hasKonsultan;
    if (hasKonsultan) {
      final kons = userBox.values.firstWhere((u) => u.username == 'konsultan');
      if (kons.password != correctHash && kons.password != '123456') {
        needsSeeding = true;
      }
    }
    
    if (needsSeeding) {
      await _seedData();
    }
    _isInitialized = true;
  }

  static Future<void> _seedData() async {
    await Hive.box<UserHive>('users').clear();
    await Hive.box<ProjectHive>('projects').clear();
    await Hive.box<ProjectMemberHive>('projectMembers').clear();
    await Hive.box<ProjectProgressHive>('projectProgress').clear();
    await Hive.box<DocumentHive>('documents').clear();
    await Hive.box<ContractorReportHive>('contractorReports').clear();
    await Hive.box<SupervisorReportHive>('supervisorReports').clear();
    await Hive.box<TimelineHive>('timelines').clear();
    await Hive.box<NotificationHive>('notifications').clear();
    await Hive.box<PhotoDocumentationHive>('photoDocumentation').clear();
    await Hive.box<ActivityHistoryHive>('activityHistory').clear();
"""

seeder_content = re.search(r"String hashPwd\(String p\) \{.*?// Users", content, re.DOTALL).group(0)
seeder_body = re.search(r"// Users.*?\}\);", content, re.DOTALL).group(0)

# Remove writeTxn
seeder_body = seeder_body.replace("});", "")

# Replace Isar models with Hive
seeder_body = seeder_body.replace("Isar()", "Hive()")
seeder_body = seeder_body.replace("IsarSchema", "HiveSchema")

# Replace putAll with loop
replacements = [
    (r"await isar\.userIsars\.putAll\(users\);", r"final b = Hive.box<UserHive>('users'); for (var i in users) { b.put(i.userId, i); }"),
    (r"await isar\.projectIsars\.putAll\(projects\);", r"final b = Hive.box<ProjectHive>('projects'); for (var i in projects) { b.put(i.projectId, i); }"),
    (r"await isar\.projectMemberIsars\.putAll\(members\);", r"final b = Hive.box<ProjectMemberHive>('projectMembers'); for (var i in members) { b.add(i); }"),
    (r"await isar\.documentIsars\.putAll\(documents\);", r"final b = Hive.box<DocumentHive>('documents'); for (var i in documents) { b.put(i.documentId, i); }"),
    (r"await isar\.contractorReportIsars\.putAll\(contractorReports\);", r"final b = Hive.box<ContractorReportHive>('contractorReports'); for (var i in contractorReports) { b.put(i.reportId, i); }"),
    (r"await isar\.supervisorReportIsars\.putAll\(supervisorReports\);", r"final b = Hive.box<SupervisorReportHive>('supervisorReports'); for (var i in supervisorReports) { b.put(i.reportId, i); }"),
    (r"await isar\.timelineIsars\.putAll\(timelines\);", r"final b = Hive.box<TimelineHive>('timelines'); for (var i in timelines) { b.put(i.timelineId, i); }"),
    (r"await isar\.notificationIsars\.putAll\(notifications\);", r"final b = Hive.box<NotificationHive>('notifications'); for (var i in notifications) { b.put(i.notificationId, i); }")
]

for old, new in replacements:
    seeder_body = re.sub(old, new, seeder_body)

final_code = "import 'package:hive_flutter/hive_flutter.dart';\nimport 'hive_models.dart';\nimport 'package:crypto/crypto.dart';\nimport 'dart:convert';\n\n" + new_class_top + "\n" + seeder_content.replace("// Users", "") + seeder_body + "\n  }\n}\n"

with open('lib/core/database/hive_database_service.dart', 'w') as f:
    f.write(final_code)
