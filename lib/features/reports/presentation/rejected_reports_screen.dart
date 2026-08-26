import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/project_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../data/models/report_model.dart';
import 'report_controller.dart';
import 'detail_data_laporan_screen.dart'; 

class RejectedReportsScreen extends ConsumerStatefulWidget {
  const RejectedReportsScreen({super.key});

  @override
  ConsumerState<RejectedReportsScreen> createState() => _RejectedReportsScreenState();
}

class _RejectedReportsScreenState extends ConsumerState<RejectedReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(contractorReportsProvider.notifier).loadReports();
      ref.read(contractsControllerProvider.notifier).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(contractorReportsProvider);
    final projectsState = ref.watch(contractsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Laporan Ditolak', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E1E1E)),
      ),
      body: reportsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (allReports) {
          final projects = projectsState.valueOrNull ?? [];
          final projectMap = {for (var p in projects) p.id: p};

          // Filter for rejected reports directly
          final latestRejectedList = allReports.where((r) => r.status.toUpperCase() == 'DITOLAK').toList();
          
          latestRejectedList.sort((a, b) => '${b.date} ${b.time}'.compareTo('${a.date} ${a.time}'));

          if (latestRejectedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Tidak ada laporan yang ditolak', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: latestRejectedList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final report = latestRejectedList[index];
              final proj = projectMap[report.projectId];
              final projectName = proj?.name ?? 'Proyek Tidak Diketahui';

              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFFF3D00)),
                ),
                color: const Color(0xFFFFECE5),
                child: InkWell(
                  onTap: () {
                    _showRejectionDetails(report, projectName);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFFF3D00), size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E))),
                              const SizedBox(height: 4),
                              Text('${report.date} • ${report.time}', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Catatan: ${report.revisionNotes}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFFF3D00), fontStyle: FontStyle.italic),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRejectionDetails(ContractorReportModel report, String projectName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Color(0xFFFF3D00)),
            SizedBox(width: 8),
            Text('Detail Penolakan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('${report.date} • ${report.time}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('Catatan Revisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF3D00))),
            const SizedBox(height: 4),
            Text(report.revisionNotes, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
