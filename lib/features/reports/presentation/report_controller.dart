import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/project_controller.dart';
import '../../timeline/presentation/timeline_controller.dart';
import '../../notifications/presentation/notification_controller.dart';
import '../data/datasources/local_report_data_source.dart';
import '../data/repositories/report_repository.dart';
import '../data/models/report_model.dart';
import '../domain/services/report_workflow_service.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dataSource = ReportLocalDataSourceImpl();
  return ReportRepositoryImpl(dataSource);
});

final reportWorkflowServiceProvider = Provider<ReportWorkflowService>((ref) {
  final reportRepository = ref.watch(reportRepositoryProvider);
  final contractRepository = ref.watch(contractRepositoryProvider);
  final timelineRepository = ref.watch(timelineRepositoryProvider);
  final notificationRepository = ref.watch(notificationRepositoryProvider);

  return ReportWorkflowService(
    reportRepository: reportRepository,
    contractRepository: contractRepository,
    timelineRepository: timelineRepository,
    notificationRepository: notificationRepository,
  );
});

final contractorReportsProvider = StateNotifierProvider<ContractorReportsController, AsyncValue<List<ContractorReportModel>>>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  final workflowService = ref.watch(reportWorkflowServiceProvider);
  return ContractorReportsController(repository, workflowService, ref);
});

final supervisorReportsProvider = StateNotifierProvider<SupervisorReportsController, AsyncValue<List<SupervisorReportModel>>>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  final workflowService = ref.watch(reportWorkflowServiceProvider);
  return SupervisorReportsController(repository, workflowService, ref);
});

class ContractorReportsController extends StateNotifier<AsyncValue<List<ContractorReportModel>>> {
  final ReportRepository _repository;
  final ReportWorkflowService _workflowService;
  final Ref _ref;

  ContractorReportsController(this._repository, this._workflowService, this._ref)
      : super(const AsyncValue.data([]));

  Future<void> loadReports() async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      final reports = await _repository.getAllContractorReports();
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRevised(String reportId) async {
    try {
      await _workflowService.markContractorReportAsRevised(reportId);
      // Not calling loadReports here because it's usually called together with submitReport
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitReport(ContractorReportModel report) async {
    state = const AsyncValue.loading();
    try {
      await _workflowService.submitContractorReport(report);
      // Reload reports and other controllers to keep the UI synchronized
      await loadReports();
      _ref.read(timelineControllerProvider.notifier).loadTimeline();
      _ref.read(notificationsControllerProvider.notifier).loadNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveReport(String reportId, String reviewerName) async {
    state = const AsyncValue.loading();
    try {
      await _workflowService.approveContractorReport(reportId, reviewerName);
      await loadReports();
      _ref.read(contractsControllerProvider.notifier).loadProjects();
      _ref.read(timelineControllerProvider.notifier).loadTimeline();
      _ref.read(notificationsControllerProvider.notifier).loadNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectReport(String reportId, String reviewerName, String revisionNotes) async {
    state = const AsyncValue.loading();
    try {
      await _workflowService.rejectContractorReport(reportId, reviewerName, revisionNotes);
      await loadReports();
      _ref.read(timelineControllerProvider.notifier).loadTimeline();
      _ref.read(notificationsControllerProvider.notifier).loadNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class SupervisorReportsController extends StateNotifier<AsyncValue<List<SupervisorReportModel>>> {
  final ReportRepository _repository;
  final ReportWorkflowService _workflowService;
  final Ref _ref;

  SupervisorReportsController(this._repository, this._workflowService, this._ref)
      : super(const AsyncValue.data([]));

  Future<void> loadReports() async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      final reports = await _repository.getAllSupervisorReports();
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitReport(SupervisorReportModel report) async {
    state = const AsyncValue.loading();
    try {
      await _workflowService.submitSupervisorReport(report);
      await loadReports();
      _ref.read(timelineControllerProvider.notifier).loadTimeline();
      _ref.read(notificationsControllerProvider.notifier).loadNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
