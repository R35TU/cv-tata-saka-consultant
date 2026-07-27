import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/laporan_harian_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../projects/presentation/project_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../data/models/report_model.dart';
import 'report_controller.dart';
import 'contractor_report_form.dart';

class DetailDataLaporanScreen extends ConsumerStatefulWidget {
  final String projectId;

  const DetailDataLaporanScreen({super.key, required this.projectId});

  @override
  ConsumerState<DetailDataLaporanScreen> createState() => _DetailDataLaporanScreenState();
}

class _DetailDataLaporanScreenState extends ConsumerState<DetailDataLaporanScreen> {
  late DateTime _weekStart;
  late DateTime _selectedDate;

  static const List<String> _monthNames = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const List<String> _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const List<String> _fullDayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();
    // Default: start at current week, selected today or a mock date matching dummy data
    _selectedDate = DateTime.now();
    _weekStart = _mondayOf(_selectedDate);
    
    Future.microtask(() {
      ref.read(projectsControllerProvider.notifier).loadProjects();
      ref.read(contractorReportsProvider.notifier).loadReports();
      ref.read(supervisorReportsProvider.notifier).loadReports();
    });
  }

  DateTime _mondayOf(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formattedSelectedDate() {
    final int wd = _selectedDate.weekday - 1;
    final dayName = _fullDayNames[wd];
    final monthName = _monthNames[_selectedDate.month];
    return '$dayName, ${_selectedDate.day.toString().padLeft(2, '0')} $monthName ${_selectedDate.year}';
  }

  String _headerMonth() {
    final monthName = _monthNames[_selectedDate.month];
    return '$monthName ${_selectedDate.year}';
  }

  void _prevWeek() => setState(() {
        _weekStart = _weekStart.subtract(const Duration(days: 7));
        if (_selectedDate.isBefore(_weekStart) || _selectedDate.isAfter(_weekStart.add(const Duration(days: 6)))) {
          _selectedDate = _weekStart;
        }
      });

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
        if (_selectedDate.isBefore(_weekStart) || _selectedDate.isAfter(_weekStart.add(const Duration(days: 6)))) {
          _selectedDate = _weekStart;
        }
      });

  void _showContractorReportDetails(ContractorReportModel report, ProjectModel proj, AppRole role) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final isRejected = report.status == 'DITOLAK';
            final isContractor = role == AppRole.kontraktor;

            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail Laporan Kontraktor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Status Badge Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: report.status == 'DISETUJUI'
                          ? const Color(0xFFE8F9EE)
                          : report.status == 'DITOLAK'
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFFFF0E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          report.status == 'DISETUJUI'
                              ? Icons.check_circle_outline
                              : report.status == 'DITOLAK'
                                  ? Icons.error_outline_rounded
                                  : Icons.access_time_rounded,
                          color: report.status == 'DISETUJUI'
                              ? const Color(0xFF00C853)
                              : report.status == 'DITOLAK'
                                  ? const Color(0xFFFF3D00)
                                  : const Color(0xFFFF9100),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${report.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: report.status == 'DISETUJUI'
                                ? const Color(0xFF00C853)
                                : report.status == 'DITOLAK'
                                    ? const Color(0xFFFF3D00)
                                    : const Color(0xFFFF9100),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isRejected && report.revisionNotes.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEF5350))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Catatan Revisi Pengawas:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F), fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(report.revisionNotes, style: const TextStyle(fontSize: 12, color: Color(0xFFC62828))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildDetailRow('Tanggal / Waktu', '${report.date} / ${report.time}'),
                  _buildDetailRow('Lokasi Kerja', report.location),
                  _buildDetailRow('Cuaca', report.weather),
                  _buildDetailRow('Progress Dilaporkan', '${(report.todayProgress * 100).toInt()}%'),
                  _buildDetailRow('Pekerjaan Hari Ini', report.tasksDone),
                  _buildDetailRow('Material Digunakan', report.materialsUsed),
                  _buildDetailRow('Alat Digunakan', report.toolsUsed),
                  _buildDetailRow('Jumlah Tenaga Kerja', report.workersCount),
                  _pdfRow('Kendala Lapangan', report.obstacles.isEmpty ? 'Tidak ada' : report.obstacles),
                  _pdfRow('Solusi Terlaksana', report.solutions.isEmpty ? 'Tidak ada' : report.solutions),
                  _pdfRow('Catatan', report.notes.isEmpty ? 'Tidak ada' : report.notes),

                  if (report.photos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Foto Dokumentasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: report.photos.length,
                        itemBuilder: (context, idx) {
                          final p = report.photos[idx];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: p.startsWith('/') || p.startsWith('file://')
                                  ? Image.file(File(p.replaceFirst('file://', '')), width: 80, height: 80, fit: BoxFit.cover)
                                  : Image.network(p, width: 80, height: 80, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Edit & Re-submit button (only if rejected and user is Contractor)
                  if (isRejected && isContractor) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(this.context).push(
                            MaterialPageRoute(
                              builder: (context) => ContractorReportForm(existingReport: report),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_document, color: Colors.white),
                        label: const Text('Revisi & Kirim Ulang Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001AFF), foregroundColor: Colors.white),
                      ),
                    ),
                  ],

                  // Change History Log
                  if (report.changeHistory.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Riwayat Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...report.changeHistory.map((h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• [${h.date}] ${h.user}: ${h.action} (${h.details})', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                        )),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSupervisorReportDetails(SupervisorReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail Laporan Pengawasan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow('Tanggal / Waktu', '${report.date} / ${report.time}'),
                  _buildDetailRow('Pengawas', report.supervisorName),
                  _buildDetailRow('Lokasi Kerja', report.location),
                  _buildDetailRow('Cuaca', report.weather),
                  _buildDetailRow('Temuan Pengawasan', report.findings),
                  _buildDetailRow('Kondisi Lapangan', report.fieldConditions),
                  _buildDetailRow('Instruksi', report.instructions),
                  _buildDetailRow('Rekomendasi', report.recommendations),
                  _pdfRow('Catatan', report.notes.isEmpty ? 'Tidak ada' : report.notes),

                  if (report.photos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Foto Dokumentasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: report.photos.length,
                        itemBuilder: (context, idx) {
                          final p = report.photos[idx];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: p.startsWith('/') || p.startsWith('file://')
                                  ? Image.file(File(p.replaceFirst('file://', '')), width: 80, height: 80, fit: BoxFit.cover)
                                  : Image.network(p, width: 80, height: 80, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Inter')),
          const SizedBox(height: 3),
          Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), height: 1.4, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color(0xFFF0F1F5)),
        ],
      ),
    );
  }

  Widget _pdfRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Inter')),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E1E1E), height: 1.4, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color(0xFFF0F1F5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final role = authState.valueOrNull?.role ?? AppRole.eksternal;

    final projectsState = ref.watch(projectsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];
    final project = projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => ProjectModel(
        id: widget.projectId,
        name: 'Memuat...',
        location: '',
        status: '',
        physicalProgress: 0.0,
        financialProgress: 0.0,
        imageUrl: '',
        description: '',
        owner: '',
        supervisor: '',
        createdAt: '',
      ),
    );

    if (project.name == 'Memuat...') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isCompleted = project.status.toLowerCase() == 'selesai';
    final Color badgeDotColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);
    final Color badgeBgColor = isCompleted ? const Color(0xFFE5EAFF) : const Color(0xFFE8F9EE);

    // Watch Contractor & Supervisor reports
    final contractorReportsState = ref.watch(contractorReportsProvider);
    final supervisorReportsState = ref.watch(supervisorReportsProvider);

    final allContractorReports = contractorReportsState.valueOrNull ?? [];
    final allSupervisorReports = supervisorReportsState.valueOrNull ?? [];

    final projectContractorReports = allContractorReports.where((r) => r.projectId == widget.projectId).toList();
    final projectSupervisorReports = allSupervisorReports.where((r) => r.projectId == widget.projectId).toList();

    // Filter reports for the selected calendar day
    final selectedDateStr = _dateKey(_selectedDate);
    final dayContractorReports = projectContractorReports.where((r) => r.date == selectedDateStr).toList();
    final daySupervisorReports = projectSupervisorReports.where((r) => r.date == selectedDateStr).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF0F1F5), height: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E), size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Data Laporan',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project header card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    project.imageUrl,
                    width: 64,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: 64,
                      height: 56,
                      color: const Color(0xFFE5E7EB),
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(20.0)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: badgeDotColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              project.status,
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: badgeDotColor, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Weekly calendar navigation
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _prevWeek,
                      icon: const Icon(Icons.chevron_left, color: Color(0xFF1E1E1E), size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(_headerMonth(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                    IconButton(
                      onPressed: _nextWeek,
                      icon: const Icon(Icons.chevron_right, color: Color(0xFF1E1E1E), size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Week column items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final day = _weekStart.add(Duration(days: i));
                    final isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;

                    final dateKeyStr = _dateKey(day);
                    final hasContractorReport = projectContractorReports.any((r) => r.date == dateKeyStr);
                    final hasSupervisorReport = projectSupervisorReports.any((r) => r.date == dateKeyStr);
                    final numReports = (hasContractorReport ? 1 : 0) + (hasSupervisorReport ? 1 : 0);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = day),
                      child: Column(
                        children: [
                          Text(
                            _dayNames[i],
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? const Color(0xFF001AFF) : const Color(0xFF9E9E9E),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF001AFF) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          
                          // Dot indicator representation
                          if (numReports > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                numReports,
                                (idx) => Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  decoration: BoxDecoration(
                                    color: idx == 0 && hasContractorReport ? const Color(0xFF001AFF) : const Color(0xFF00C853),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 5),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Selected Day Label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(_formattedSelectedDate(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
          ),

          // Mixed daily reports list
          Expanded(
            child: (dayContractorReports.isEmpty && daySupervisorReports.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note_outlined, size: 42, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada laporan pada hari ini',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    children: [
                      ...dayContractorReports.map((report) => LaporanHarianCard(
                            title: 'Laporan Harian Kontraktor ( STA: ${report.location} )',
                            createdAt: 'Diserahkan pukul ${report.time}',
                            iconColor: const Color(0xFF001AFF),
                            iconBackgroundColor: const Color(0xFFE5EAFF),
                            onTap: () => _showContractorReportDetails(report, project, role),
                          )),
                      ...daySupervisorReports.map((report) => LaporanHarianCard(
                            title: 'Laporan Harian Pengawasan ( STA: ${report.location} )',
                            createdAt: 'Diaudit pukul ${report.time}',
                            iconColor: const Color(0xFF00C853),
                            iconBackgroundColor: const Color(0xFFE8F9EE),
                            onTap: () => _showSupervisorReportDetails(report),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
