import 'package:uuid/uuid.dart';
import '../../../projects/data/repositories/project_repository.dart';
import '../../../timeline/data/repositories/timeline_repository.dart';
import '../../../timeline/data/models/timeline_model.dart';
import '../../../notifications/data/repositories/notification_repository.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/models/report_model.dart';

class ReportWorkflowService {
  final ReportRepository reportRepository;
  final ContractRepository contractRepository;
  final TimelineRepository timelineRepository;
  final NotificationRepository notificationRepository;

  ReportWorkflowService({
    required this.reportRepository,
    required this.contractRepository,
    required this.timelineRepository,
    required this.notificationRepository,
  });

  Future<void> submitContractorReport(ContractorReportModel report) async {
    // Check if report already exists
    final existingReports = await reportRepository.getAllContractorReports();
    final exists = existingReports.any((r) => r.id == report.id);

    // Save report to data source
    if (exists) {
      await reportRepository.updateContractorReport(report);
    } else {
      await reportRepository.addContractorReport(report);
    }

    // Get project name
    final project = await contractRepository.getProjectById(report.projectId);
    final projectName = project?.name ?? 'Proyek';

    // Log to timeline
    final timelineItem = TimelineModel(
      id: const Uuid().v4(),
      title: 'Laporan Harian Kontraktor dikirim',
      description: 'Laporan harian proyek "$projectName" tanggal ${report.date} dikirim oleh kontraktor.',
      user: 'Budi Kontraktor',
      role: 'Kontraktor',
      icon: 'report',
      createdAt: '${report.date} ${report.time}',
    );
    await timelineRepository.addTimeline(timelineItem);

    // Send notification to Konsultan (Supervisors)
    final notificationItem = NotificationModel(
      id: const Uuid().v4(),
      title: 'Approval Laporan Harian',
      message: 'Laporan harian proyek "$projectName" tanggal ${report.date} menunggu verifikasi.',
      type: 'Approval',
      isRead: false,
      createdAt: DateTime.now().toString().substring(0, 16),
    );
    await notificationRepository.addNotification(notificationItem);
  }

  Future<void> approveContractorReport(String reportId, String reviewerName) async {
    final reports = await reportRepository.getAllContractorReports();
    final report = reports.firstWhere((r) => r.id == reportId);
    
    final updatedReport = report.copyWith(
      status: 'DISETUJUI',
      reviewerName: reviewerName,
      verificationDate: DateTime.now().toString().substring(0, 16),
      changeHistory: [
        ...report.changeHistory,
        ReportHistory(
          date: DateTime.now().toString().substring(0, 16),
          user: reviewerName,
          action: 'DISETUJUI',
          details: 'Laporan disetujui dan diverifikasi oleh Konsultan.',
        ),
      ],
    );

    await reportRepository.updateContractorReport(updatedReport);

    // Update Project Progress (temporarily disabled for Day 1)
    final project = await contractRepository.getProjectById(report.projectId);
    if (project != null) {
      final newPhysicalProgress = report.todayProgress; // Mock progress for timeline
      final newStatus = project.status;
      
      final updatedProject = project.copyWith(
        status: newStatus,
      );
      await contractRepository.updateProject(updatedProject);

      // Log to timeline
      final timelineItem = TimelineModel(
        id: const Uuid().v4(),
        title: 'Laporan Harian Disetujui',
        description: 'Laporan harian proyek "${project.name}" tanggal ${report.date} disetujui. Progres fisik bertambah menjadi ${(newPhysicalProgress * 100).toInt()}%.',
        user: reviewerName,
        role: 'Konsultan',
        icon: 'check',
        createdAt: DateTime.now().toString().substring(0, 16),
      );
      await timelineRepository.addTimeline(timelineItem);

      // Send notification to Contractor
      final notificationItem = NotificationModel(
        id: const Uuid().v4(),
        title: 'Laporan Disetujui',
        message: 'Laporan harian proyek "${project.name}" tanggal ${report.date} telah disetujui oleh Konsultan.',
        type: 'Approval',
        isRead: false,
        createdAt: DateTime.now().toString().substring(0, 16),
      );
      await notificationRepository.addNotification(notificationItem);
    }
  }

  Future<void> rejectContractorReport(String reportId, String reviewerName, String revisionNotes) async {
    final reports = await reportRepository.getAllContractorReports();
    final report = reports.firstWhere((r) => r.id == reportId);
    
    final updatedReport = report.copyWith(
      status: 'DITOLAK',
      reviewerName: reviewerName,
      verificationDate: DateTime.now().toString().substring(0, 16),
      revisionNotes: revisionNotes,
      changeHistory: [
        ...report.changeHistory,
        ReportHistory(
          date: DateTime.now().toString().substring(0, 16),
          user: reviewerName,
          action: 'DITOLAK',
          details: 'Ditolak dengan catatan: $revisionNotes',
        ),
      ],
    );

    await reportRepository.updateContractorReport(updatedReport);

    final project = await contractRepository.getProjectById(report.projectId);
    final projectName = project?.name ?? 'Proyek';

    // Log to timeline
    final timelineItem = TimelineModel(
      id: const Uuid().v4(),
      title: 'Laporan Harian Ditolak',
      description: 'Laporan harian proyek "$projectName" tanggal ${report.date} ditolak oleh pengawas. Alasan: $revisionNotes',
      user: reviewerName,
      role: 'Konsultan',
      icon: 'close',
      createdAt: DateTime.now().toString().substring(0, 16),
    );
    await timelineRepository.addTimeline(timelineItem);

    // Send notification to Contractor
    final notificationItem = NotificationModel(
      id: const Uuid().v4(),
      title: 'Laporan Ditolak / Perlu Revisi',
      message: 'Laporan harian proyek "$projectName" tanggal ${report.date} memerlukan revisi: $revisionNotes',
      type: 'Revisi',
      isRead: false,
      createdAt: DateTime.now().toString().substring(0, 16),
    );
    await notificationRepository.addNotification(notificationItem);
  }

  Future<void> markContractorReportAsRevised(String reportId) async {
    final reports = await reportRepository.getAllContractorReports();
    final report = reports.firstWhere((r) => r.id == reportId);
    
    final updatedReport = report.copyWith(
      status: 'DIREVISI',
    );

    await reportRepository.updateContractorReport(updatedReport);
  }

  Future<void> submitSupervisorReport(SupervisorReportModel report) async {
    await reportRepository.addSupervisorReport(report);

    final project = await contractRepository.getProjectById(report.projectId);
    final projectName = project?.name ?? 'Proyek';

    // Log to timeline
    final timelineItem = TimelineModel(
      id: const Uuid().v4(),
      title: 'Laporan Pengawasan Ditambahkan',
      description: 'Laporan pengawasan harian proyek "$projectName" di STA ${report.location} ditambahkan oleh Konsultan. Temuan: ${report.findings}',
      user: report.supervisorName,
      role: 'Konsultan',
      icon: 'visibility',
      createdAt: '${report.date} ${report.time}',
    );
    await timelineRepository.addTimeline(timelineItem);

    // Send notification about new supervisor report
    final notificationItem = NotificationModel(
      id: const Uuid().v4(),
      title: 'Temuan Pengawasan Baru',
      message: 'Laporan pengawasan proyek "$projectName" diunggah. Temuan: ${report.findings}',
      type: 'Timeline Baru',
      isRead: false,
      createdAt: DateTime.now().toString().substring(0, 16),
    );
    await notificationRepository.addNotification(notificationItem);
  }
}
