import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/project_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/report_model.dart';
import 'report_controller.dart';

class PendingApprovalsScreen extends ConsumerStatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  ConsumerState<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends ConsumerState<PendingApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(contractorReportsProvider.notifier).loadReports();
      ref.read(contractsControllerProvider.notifier).loadProjects();
    });
  }

  void _showReportDetail(ContractorReportModel report, String projectName, String reviewerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Review Laporan Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Project Name Header
                  Text(projectName, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF001AFF), fontFamily: 'Inter')),
                  const SizedBox(height: 8),
                  Text('Diajukan tanggal: ${report.date} pukul ${report.time}', style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontFamily: 'Inter')),
                  const Divider(height: 24),

                  // Detail rows
                  _buildDetailSection('Informasi Umum', [
                    _buildRow('Lokasi / STA', report.location),
                    _buildRow('Cuaca', report.weather),
                    _buildRow('Progress Hari Ini', '${(report.todayProgress * 100).toInt()}%'),
                  ]),
                  
                  _buildDetailSection('Pekerjaan & Tenaga Kerja', [
                    _buildRow('Pekerjaan Hari Ini', report.tasksDone),
                    _buildRow('Material', report.materialsUsed),
                    _buildRow('Alat', report.toolsUsed),
                    _buildRow('Tenaga Kerja', report.workersCount),
                  ]),

                  _buildDetailSection('Kendala & Solusi', [
                    _buildRow('Kendala Lapangan', report.obstacles.isEmpty ? 'Tidak ada' : report.obstacles),
                    _buildRow('Solusi Kendala', report.solutions.isEmpty ? 'Tidak ada' : report.solutions),
                    _buildRow('Catatan', report.notes.isEmpty ? 'Tidak ada' : report.notes),
                  ]),

                  if (report.photos.isNotEmpty) ...[
                    const Text('Foto Dokumentasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E))),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: report.photos.length,
                        itemBuilder: (context, idx) {
                          final p = report.photos[idx];
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: p.startsWith('/') || p.startsWith('file://')
                                  ? Image.file(File(p.replaceFirst('file://', '')), width: 90, height: 90, fit: BoxFit.cover)
                                  : Image.network(p, width: 90, height: 90, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (report.attachments.isNotEmpty) ...[
                    const Text('Lampiran File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E))),
                    const SizedBox(height: 8),
                    ...report.attachments.map((file) => Card(
                          elevation: 0,
                          color: const Color(0xFFF5F6FA),
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                            title: Text(file, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Approval Buttons (Consultant/Reviewer only)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close sheet
                            _showRejectDialog(report.id, reviewerName);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF3D00), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Tolak & Revisi', style: TextStyle(color: Color(0xFFFF3D00), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await ref.read(contractorReportsProvider.notifier).approveReport(report.id, reviewerName);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Laporan disetujui. Progress proyek terupdate.')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text('Setujui Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRejectDialog(String reportId, String reviewerName) {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Laporan Harian', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tuliskan alasan penolakan / catatan revisi untuk Kontraktor (wajib):', style: TextStyle(fontSize: 12.5, height: 1.4)),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Spesifikasi sirtu tidak sesuai standar kontrak...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (noteCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan revisi wajib diisi.')));
                return;
              }
              await ref.read(contractorReportsProvider.notifier).rejectReport(reportId, reviewerName, noteCtrl.text.trim());
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan ditolak. Notifikasi revisi terkirim ke Kontraktor.')));
              }
            },
            child: const Text('Kirim Revisi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String sectionTitle, List<Widget> rows) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFF5F6FA),
            child: Text(sectionTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, fontFamily: 'Inter')),
          ),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontFamily: 'Inter')),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), height: 1.3, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final reviewerName = user?.name ?? 'Konsultan';

    final projectsState = ref.watch(contractsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];

    final reportsState = ref.watch(contractorReportsProvider);
    final allReports = reportsState.valueOrNull ?? [];
    
    // Filter pending reports directly by status since old reports will be DIREVISI
    final pendingReports = allReports.where((r) => r.status.toUpperCase() == 'MENUNGGU VERIFIKASI').toList();
    pendingReports.sort((a, b) => '${b.date} ${b.time}'.compareTo('${a.date} ${a.time}')); // newest first

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Permintaan Konfirmasi', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: reportsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada permintaan konfirmasi laporan.',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingReports.length,
                  itemBuilder: (context, index) {
                    final report = pendingReports[index];
                    final proj = projects.firstWhere(
                      (p) => p.id == report.projectId,
                      orElse: () => ContractModel(
                        id: report.projectId,
                        type: '',
                        name: 'Kegiatan Tidak Ditemukan',
                        location: '',
                        status: '',
                        imageUrl: '',
                        description: '',
                        owner: '',
                        supervisor: '',
                        createdAt: '',
                        startDate: '',
                        endDate: '',
                        dinas: [],
                        fundingSource: '',
                      ),
                    );

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFF0F1F5))),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFF0E0),
                          child: Icon(Icons.file_present_rounded, color: Colors.orange.shade800),
                        ),
                        title: Text(proj.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Pekerjaan: ${report.tasksDone}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF555555), fontFamily: 'Inter'), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('Tanggal: ${report.date} • Kemajuan: ${(report.todayProgress * 100).toInt()}%', style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontFamily: 'Inter')),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => _showReportDetail(report, proj.name, reviewerName),
                      ),
                    );
                  },
                ),
    );
  }
}
