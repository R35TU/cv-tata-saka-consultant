import '../datasources/local_report_data_source.dart';
import '../models/report_model.dart';

abstract class ReportRepository {
  Future<void> init();
  Future<List<ContractorReportModel>> getContractorReports(String projectId);
  Future<List<ContractorReportModel>> getAllContractorReports();
  Future<void> addContractorReport(ContractorReportModel report);
  Future<void> updateContractorReport(ContractorReportModel report);
  Future<void> deleteContractorReport(String id);

  Future<List<SupervisorReportModel>> getSupervisorReports(String projectId);
  Future<List<SupervisorReportModel>> getAllSupervisorReports();
  Future<void> addSupervisorReport(SupervisorReportModel report);
}

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource localDataSource;

  ReportRepositoryImpl(this.localDataSource);

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<List<ContractorReportModel>> getContractorReports(String projectId) =>
      localDataSource.getContractorReports(projectId);

  @override
  Future<List<ContractorReportModel>> getAllContractorReports() =>
      localDataSource.getAllContractorReports();

  @override
  Future<void> addContractorReport(ContractorReportModel report) =>
      localDataSource.addContractorReport(report);

  @override
  Future<void> updateContractorReport(ContractorReportModel report) =>
      localDataSource.updateContractorReport(report);

  @override
  Future<void> deleteContractorReport(String id) =>
      localDataSource.deleteContractorReport(id);

  @override
  Future<List<SupervisorReportModel>> getSupervisorReports(String projectId) =>
      localDataSource.getSupervisorReports(projectId);

  @override
  Future<List<SupervisorReportModel>> getAllSupervisorReports() =>
      localDataSource.getAllSupervisorReports();

  @override
  Future<void> addSupervisorReport(SupervisorReportModel report) =>
      localDataSource.addSupervisorReport(report);
}
