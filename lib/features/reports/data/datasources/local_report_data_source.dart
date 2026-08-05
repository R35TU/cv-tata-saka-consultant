import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/database/hive_database_service.dart';
import '../../../../core/database/hive_models.dart';
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
  @override
  Future<void> init() async {
    await HiveDatabaseService.initDb();
  }

  @override
  Future<List<ContractorReportModel>> getContractorReports(String projectId) async {
    final box = Hive.box<ContractorReportHive>('contractorReports');
    final list = box.values.where((r) => r.projectId == projectId).toList();
    return _toContractorModels(list);
  }

  @override
  Future<List<ContractorReportModel>> getAllContractorReports() async {
    final box = Hive.box<ContractorReportHive>('contractorReports');
    final list = box.values.toList();
    return _toContractorModels(list);
  }

  List<ContractorReportModel> _toContractorModels(List<ContractorReportHive> list) {
    return list.map((raw) => ContractorReportModel(
      id: raw.reportId,
      projectId: raw.projectId,
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
    final box = Hive.box<ContractorReportHive>('contractorReports');
    final hiveReport = ContractorReportHive()
      ..reportId = report.id
      ..projectId = report.projectId
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
      ..changeHistory = report.changeHistory.map((h) => ReportHistoryHive()
        ..date = h.date
        ..user = h.user
        ..action = h.action
        ..details = h.details
      ).toList();
    await box.put(report.id, hiveReport);
  }

  @override
  Future<void> updateContractorReport(ContractorReportModel report) async {
    await addContractorReport(report);
  }

  @override
  Future<void> deleteContractorReport(String id) async {
    final box = Hive.box<ContractorReportHive>('contractorReports');
    await box.delete(id);
  }

  @override
  Future<List<SupervisorReportModel>> getSupervisorReports(String projectId) async {
    final box = Hive.box<SupervisorReportHive>('supervisorReports');
    final list = box.values.where((r) => r.projectId == projectId).toList();
    return _toSupervisorModels(list);
  }

  @override
  Future<List<SupervisorReportModel>> getAllSupervisorReports() async {
    final box = Hive.box<SupervisorReportHive>('supervisorReports');
    final list = box.values.toList();
    return _toSupervisorModels(list);
  }

  List<SupervisorReportModel> _toSupervisorModels(List<SupervisorReportHive> list) {
    return list.map((raw) => SupervisorReportModel(
      id: raw.reportId,
      projectId: raw.projectId,
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
    final box = Hive.box<SupervisorReportHive>('supervisorReports');
    final hiveReport = SupervisorReportHive()
      ..reportId = report.id
      ..projectId = report.projectId
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
    await box.put(report.id, hiveReport);
  }

  @override
  Future<void> seedReports() async {}
}
