import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/report_model.dart';
import 'report_controller.dart';
import '../../projects/presentation/project_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import 'contractor_report_form.dart';

class ContractorReportStatusScreen extends ConsumerStatefulWidget {
  const ContractorReportStatusScreen({super.key});

  @override
  ConsumerState<ContractorReportStatusScreen> createState() => _ContractorReportStatusScreenState();
}

class _ContractorReportStatusScreenState extends ConsumerState<ContractorReportStatusScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(contractorReportsProvider.notifier).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(contractorReportsProvider);
    final projectsState = ref.watch(contractsControllerProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Status Laporan Anda', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1E1E)),
      ),
      body: reportsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Gagal memuat: $err')),
        data: (allReports) {
          final projects = projectsState.valueOrNull ?? [];
          final myProjectIds = projects.map((p) => p.id).toSet();
          
          // Filter reports belonging to contractor's projects, AND hide 'DIREVISI'
          final myReports = allReports.where((r) {
            return myProjectIds.contains(r.projectId) && r.status.toUpperCase() != 'DIREVISI';
          }).toList();
          
          // Sort ascending by date/time (newest at bottom)
          myReports.sort((a, b) => '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}'));

          if (myReports.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: myReports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final report = myReports[index];
              final project = projects.where((p) => p.id == report.projectId).firstOrNull;
              
              return _buildReportCard(report, project?.name ?? 'Proyek Tidak Diketahui');
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada laporan terkirim.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ContractorReportModel report, String projectName) {
    final status = report.status.toUpperCase();
    Color statusColor;
    Color bgColor;
    IconData statusIcon;

    if (status == 'DISETUJUI') {
      statusColor = const Color(0xFF00C853);
      bgColor = const Color(0xFFE8F9EE);
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'DITOLAK') {
      statusColor = const Color(0xFFFF3D00);
      bgColor = const Color(0xFFFFECE5);
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = const Color(0xFFFF9100);
      bgColor = const Color(0xFFFFF4E5);
      statusIcon = Icons.hourglass_empty_rounded;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor, width: 1.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('${report.date} • ${report.time} • ${(report.todayProgress * 100).toInt()}% Selesai', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
          ),
          children: [
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 8),
            if (status == 'DITOLAK' && report.revisionNotes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF3D00).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFFF3D00)),
                        SizedBox(width: 6),
                        Text('Alasan Penolakan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF3D00))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(report.revisionNotes, style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E))),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ContractorReportForm(existingReport: report)),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Perbaiki Laporan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3D00),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Laporan ini telah dikirim dan ${status.toLowerCase()}.', style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
              ),
          ],
        ),
      ),
    );
  }
}
