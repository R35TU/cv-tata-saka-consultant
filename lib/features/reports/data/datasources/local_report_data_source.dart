import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../models/report_model.dart';

abstract class ReportLocalDataSource {
  Future<void> init();
  Future<List<ContractorReportModel>> getContractorReports(String projectId);
  Future<List<ContractorReportModel>> getAllContractorReports();
  Future<void> addContractorReport(ContractorReportModel report);
  Future<void> updateContractorReport(ContractorReportModel report);
  Future<void> deleteContractorReport(String id);
  
  Future<List<SupervisorReportModel>> getSupervisorReports(String projectId);
  Future<List<SupervisorReportModel>> getAllSupervisorReports();
  Future<void> addSupervisorReport(SupervisorReportModel report);
  Future<void> seedReports();
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  Isar? _db;

  Future<Isar> get db async {
    if (_db != null) return _db!;
    _db = await IsarDatabaseService.db;
    return _db!;
  }

  @override
  Future<void> init() async {
    await db;
  }

  @override
  Future<List<ContractorReportModel>> getContractorReports(String projectId) async {
    final database = await db;
    final list = await database.contractorReportIsars.filter().contractIdEqualTo(projectId).findAll();
    return _toContractorModels(list);
  }

  @override
  Future<List<ContractorReportModel>> getAllContractorReports() async {
    final database = await db;
    final list = await database.contractorReportIsars.where().findAll();
    return _toContractorModels(list);
  }

  List<ContractorReportModel> _toContractorModels(List<ContractorReportIsar> list) {
    return list.map((raw) => ContractorReportModel(
      id: raw.reportId,
      projectId: raw.contractId,
      date: raw.date,
      time: raw.time,
      weather: raw.weather,
      location: raw.location,
      todayProgress: raw.todayProgress,
      tasksDone: raw.tasksDone,
      materialsUsed: raw.materialsUsed,
      toolsUsed: raw.toolsUsed,
      workersCount: raw.workersCount,
      obstacles: raw.obstacles,
      solutions: raw.solutions,
      notes: raw.notes,
      photos: raw.photos,
      attachments: raw.attachments,
      status: raw.status,
      reviewerName: raw.reviewerName,
      verificationDate: raw.verificationDate,
      revisionNotes: raw.revisionNotes,
      changeHistory: raw.changeHistory.map((h) => ReportHistory(
        date: h.date,
        user: h.user,
        action: h.action,
        details: h.details,
      )).toList(),
    )).toList();
  }

  @override
  Future<void> addContractorReport(ContractorReportModel report) async {
    final database = await db;
    await database.writeTxn(() async {
      final isarReport = ContractorReportIsar()
        ..reportId = report.id
        ..contractId = report.projectId
        ..date = report.date
        ..time = report.time
        ..weather = report.weather
        ..location = report.location
        ..todayProgress = report.todayProgress
        ..tasksDone = report.tasksDone
        ..materialsUsed = report.materialsUsed
        ..toolsUsed = report.toolsUsed
        ..workersCount = report.workersCount
        ..obstacles = report.obstacles
        ..solutions = report.solutions
        ..notes = report.notes
        ..photos = report.photos
        ..attachments = report.attachments
        ..status = report.status
        ..reviewerName = report.reviewerName
        ..verificationDate = report.verificationDate
        ..revisionNotes = report.revisionNotes
        ..changeHistory = report.changeHistory.map((h) => ReportHistoryIsar()
          ..date = h.date
          ..user = h.user
          ..action = h.action
          ..details = h.details
        ).toList();
      await database.contractorReportIsars.put(isarReport);
    });
  }

  @override
  Future<void> updateContractorReport(ContractorReportModel report) async {
    final database = await db;
    final existing = await database.contractorReportIsars.filter().reportIdEqualTo(report.id).findFirst();
    await database.writeTxn(() async {
      final isarReport = (existing ?? ContractorReportIsar())
        ..reportId = report.id
        ..contractId = report.projectId
        ..date = report.date
        ..time = report.time
        ..weather = report.weather
        ..location = report.location
        ..todayProgress = report.todayProgress
        ..tasksDone = report.tasksDone
        ..materialsUsed = report.materialsUsed
        ..toolsUsed = report.toolsUsed
        ..workersCount = report.workersCount
        ..obstacles = report.obstacles
        ..solutions = report.solutions
        ..notes = report.notes
        ..photos = report.photos
        ..attachments = report.attachments
        ..status = report.status
        ..reviewerName = report.reviewerName
        ..verificationDate = report.verificationDate
        ..revisionNotes = report.revisionNotes
        ..changeHistory = report.changeHistory.map((h) => ReportHistoryIsar()
          ..date = h.date
          ..user = h.user
          ..action = h.action
          ..details = h.details
        ).toList();
      await database.contractorReportIsars.put(isarReport);
    });
  }

  @override
  Future<void> deleteContractorReport(String id) async {
    final database = await db;
    final existing = await database.contractorReportIsars.filter().reportIdEqualTo(id).findFirst();
    if (existing != null) {
      await database.writeTxn(() async {
        await database.contractorReportIsars.delete(existing.id);
      });
    }
  }

  @override
  Future<List<SupervisorReportModel>> getSupervisorReports(String projectId) async {
    final database = await db;
    final list = await database.supervisorReportIsars.filter().contractIdEqualTo(projectId).findAll();
    return _toSupervisorModels(list);
  }

  @override
  Future<List<SupervisorReportModel>> getAllSupervisorReports() async {
    final database = await db;
    final list = await database.supervisorReportIsars.where().findAll();
    return _toSupervisorModels(list);
  }

  List<SupervisorReportModel> _toSupervisorModels(List<SupervisorReportIsar> list) {
    return list.map((raw) => SupervisorReportModel(
      id: raw.reportId,
      projectId: raw.contractId,
      date: raw.date,
      time: raw.time,
      supervisorName: raw.supervisorName,
      location: raw.location,
      weather: raw.weather,
      findings: raw.findings,
      fieldConditions: raw.fieldConditions,
      instructions: raw.instructions,
      recommendations: raw.recommendations,
      notes: raw.notes,
      photos: raw.photos,
      attachments: raw.attachments,
    )).toList();
  }

  @override
  Future<void> addSupervisorReport(SupervisorReportModel report) async {
    final database = await db;
    await database.writeTxn(() async {
      final isarReport = SupervisorReportIsar()
        ..reportId = report.id
        ..contractId = report.projectId
        ..date = report.date
        ..time = report.time
        ..supervisorName = report.supervisorName
        ..location = report.location
        ..weather = report.weather
        ..findings = report.findings
        ..fieldConditions = report.fieldConditions
        ..instructions = report.instructions
        ..recommendations = report.recommendations
        ..notes = report.notes
        ..photos = report.photos
        ..attachments = report.attachments;
      await database.supervisorReportIsars.put(isarReport);
    });
  }

  @override
  Future<void> seedReports() async {
    // Already handled in IsarDatabaseService
  }
}
