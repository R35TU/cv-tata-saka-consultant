import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/project_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../data/models/report_model.dart';
import 'report_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class RekapLaporanScreen extends ConsumerStatefulWidget {
  const RekapLaporanScreen({super.key});

  @override
  ConsumerState<RekapLaporanScreen> createState() => _RekapLaporanScreenState();
}

class _RekapLaporanScreenState extends ConsumerState<RekapLaporanScreen> {
  String? _selectedProjectId;
  String _selectedPeriod = 'Mingguan';
  int _chartOffset = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(contractsControllerProvider.notifier).loadProjects();
      ref.read(contractorReportsProvider.notifier).loadReports();
      ref.read(supervisorReportsProvider.notifier).loadReports();
    });
  }

  void _simulatePDFExport(ContractModel? selectedProject, double physProgress, double supProgress) {
    if (selectedProject == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        double progress = 0.0;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(milliseconds: 250), () {
              if (progress < 1.0) {
                if (ctx.mounted) {
                  setDialogState(() {
                    progress = (progress + 0.20).clamp(0.0, 1.0);
                  });
                }
              } else {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _showPDFPreviewSheet(selectedProject, physProgress, supProgress);
                });
              }
            });
            return AlertDialog(
              title: const Text('Mengekspor PDF Rekap', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress, color: const Color(0xFF6A1B9A), backgroundColor: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Text('Menyusun tata letak rekap... ${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 11.5)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPDFPreviewSheet(ContractModel project, double physProgress, double supProgress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              color: Colors.grey.shade800, // Look like a PDF viewer dark theme
              child: Column(
                children: [
                  // App Bar like header
                  Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                        const Expanded(
                          child: Text(
                            'Rekap_Laporan_Proyek.pdf',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Inter'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('File PDF berhasil dibagikan.')));
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // PDF Mock Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            const Center(
                              child: Text(
                                'LAPORAN REKAP BULANAN PROYEK KONSTRUKSI',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black, decoration: TextDecoration.underline),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Center(
                              child: Text(
                                'CV. TATA SAKA CONSULTANT',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Specs
                            _pdfRow('Nama Proyek', project.name),
                            _pdfRow('Lokasi', project.location),
                            _pdfRow('Kontraktor', project.owner),
                            _pdfRow('Konsultan Pengawas', project.supervisor),
                            _pdfRow('Sumber Dana', project.fundingSource),
                            _pdfRow('Tanggal Cetak', DateTime.now().toString().substring(0, 16)),
                            const Divider(color: Colors.black, thickness: 1.5, height: 32),

                            // Dynamic calculations
                            const Text('1. KEMAJUAN PROYEK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            _pdfRow('Kemajuan Fisik Saat Ini', '${(physProgress * 100).toInt()}%'),
                            _pdfRow('Kemajuan Finansial', '${(supProgress * 100).toInt()}%'),
                            _pdfRow('Status Proyek', project.status),
                            const SizedBox(height: 20),

                            const Text('2. REKAPITULASI DOKUMEN & LAPORAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            _pdfRow('Total Laporan Harian Terdaftar', '3 Laporan'),
                            _pdfRow('Status Approval Laporan', '2 Disetujui, 1 Menunggu Verifikasi'),
                            _pdfRow('Catatan Audit Pengawas', 'Semua pekerjaan berjalan sesuai Rencana Mutu Kontrak (RMK).'),
                            const SizedBox(height: 48),

                            // Signatures
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    const Text('Disetujui Oleh:', style: TextStyle(fontSize: 10)),
                                    const Text('Konsultan Pengawas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 40),
                                    Text(project.supervisor, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Diajukan Oleh:', style: TextStyle(fontSize: 10)),
                                    const Text('Kontraktor Pelaksana', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 40),
                                    Text(project.owner, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _pdfRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.black87))),
          const Text(': ', style: TextStyle(fontSize: 10.5, color: Colors.black87)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(contractsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];

    final contractorReports = ref.watch(contractorReportsProvider).valueOrNull ?? [];
    final supervisorReports = ref.watch(supervisorReportsProvider).valueOrNull ?? [];

    // Resolve selected project
    final selectedProject = _selectedProjectId != null
        ? projects.firstWhere((p) => p.id == _selectedProjectId)
        : (projects.isNotEmpty ? projects.first : null);

    double actualPhysicalProgress = 0.0;
    double actualSupervisorProgress = 0.0;
    int totalApprovedReports = 0;

    if (selectedProject != null) {
      final approvedReports = contractorReports.where((r) => r.projectId == selectedProject.id && r.status == 'DISETUJUI').toList();
      approvedReports.sort((a, b) => a.date.compareTo(b.date));
      totalApprovedReports = approvedReports.length;

      for (var r in approvedReports) {
        actualPhysicalProgress += r.todayProgress;
      }
      if (actualPhysicalProgress > 1.0) actualPhysicalProgress = 1.0;

      final projectSupReports = supervisorReports.where((r) => r.projectId == selectedProject.id).toList();
      projectSupReports.sort((a, b) => a.date.compareTo(b.date));
      
      if (projectSupReports.isNotEmpty) {
        String lastSupDate = projectSupReports.last.date;
        double progressAtLastSup = 0.0;
        for (var r in approvedReports) {
          if (r.date.compareTo(lastSupDate) <= 0) {
            progressAtLastSup += r.todayProgress;
          }
        }
        actualSupervisorProgress = progressAtLastSup;
        if (actualSupervisorProgress > 1.0) actualSupervisorProgress = 1.0;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Rekap Laporan', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: projects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter block
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF0F1F5))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Filter Rekap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E1E1E))),
                        const SizedBox(height: 12),
                        const Text('Pilih Proyek', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedProjectId ?? projects.first.id,
                          items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => setState(() => _selectedProjectId = val),
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                        ),
                        const SizedBox(height: 12),
                        const Text('Periode', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedPeriod,
                          items: const [
                            DropdownMenuItem(value: 'Mingguan', child: Text('Mingguan')),
                            DropdownMenuItem(value: 'Bulanan', child: Text('Bulanan')),
                            DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                          ],
                          onChanged: (val) => setState(() {
                            _selectedPeriod = val!;
                            _chartOffset = 1;
                          }),
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary stats block
                  if (selectedProject != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F1F5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedProject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF001AFF))),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Progres Fisik', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  Text('${(actualPhysicalProgress * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C853))),
                                ],
                              ),
                              Container(height: 30, width: 1, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('Progress Pengawasan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  Text('${(actualSupervisorProgress * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF001AFF))),
                                ],
                              ),
                              Container(height: 30, width: 1, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('Laporan Harian', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  Text('$totalApprovedReports Laporan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rekap Chart Illustration (Modern styling)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0F1F5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kurva Kemajuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Inter')),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(const Color(0xFF00C853), 'Fisik'),
                              const SizedBox(width: 16),
                              _buildLegendItem(const Color(0xFF001AFF), 'Pengawasan'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: _buildLineChart(selectedProject, contractorReports, supervisorReports),
                          ),
                          if (_selectedPeriod != 'Semua') ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _chartOffset > 1 
                                      ? () => setState(() => _chartOffset = math.max(1, _chartOffset - (_selectedPeriod == 'Mingguan' ? 7 : 30))) 
                                      : null,
                                  child: const Row(
                                    children: [Icon(Icons.arrow_back_ios, size: 12), SizedBox(width: 4), Text('Previous')],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _chartOffset + (_selectedPeriod == 'Mingguan' ? 7 : 30) - 1 < 100
                                      ? () => setState(() => _chartOffset += (_selectedPeriod == 'Mingguan' ? 7 : 30))
                                      : null,
                                  child: const Row(
                                    children: [Text('Next'), SizedBox(width: 4), Icon(Icons.arrow_forward_ios, size: 12)],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Export PDF Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _simulatePDFExport(selectedProject, actualPhysicalProgress, actualSupervisorProgress),
                        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                        label: const Text('Export Laporan ke PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Inter')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLineChart(ContractModel project, List<ContractorReportModel> cReports, List<SupervisorReportModel> sReports) {
    DateTime startDate = DateTime.tryParse(project.startDate) ?? DateTime.now();
    DateTime endDate = DateTime.tryParse(project.endDate) ?? startDate.add(const Duration(days: 100));
    
    int totalProjectDays = endDate.difference(startDate).inDays + 1;
    if (totalProjectDays <= 0) totalProjectDays = 100;

    int windowSize = _selectedPeriod == 'Mingguan' ? 7 : (_selectedPeriod == 'Bulanan' ? 30 : totalProjectDays);
    int startDay = _selectedPeriod == 'Semua' ? 1 : _chartOffset;
    int endDay = startDay + windowSize - 1;
    
    if (endDay > totalProjectDays) endDay = totalProjectDays;

    var approvedCReports = cReports.where((r) => r.projectId == project.id && r.status == 'DISETUJUI').toList();
    approvedCReports.sort((a, b) => a.date.compareTo(b.date));
    
    var projectSReports = sReports.where((r) => r.projectId == project.id).toList();
    projectSReports.sort((a, b) => a.date.compareTo(b.date));

    List<FlSpot> physicalSpots = [];
    List<FlSpot> supervisorSpots = [];

    double currentPhys = 0.0;
    double currentSup = 0.0;

    int cIdx = 0;
    int sIdx = 0;

    for (int i = 1; i <= totalProjectDays; i++) {
        DateTime currentDayDate = startDate.add(Duration(days: i - 1));
        String dateStr = "${currentDayDate.year.toString().padLeft(4, '0')}-${currentDayDate.month.toString().padLeft(2, '0')}-${currentDayDate.day.toString().padLeft(2, '0')}";

        // Accumulate any reports that are on OR BEFORE this date (this naturally catches old reports on Day 1)
        while (cIdx < approvedCReports.length && approvedCReports[cIdx].date.compareTo(dateStr) <= 0) {
            currentPhys += approvedCReports[cIdx].todayProgress * 100;
            if (currentPhys > 100.0) currentPhys = 100.0;
            cIdx++;
        }

        bool hasSupReportToday = false;
        while (sIdx < projectSReports.length && projectSReports[sIdx].date.compareTo(dateStr) <= 0) {
            hasSupReportToday = true;
            sIdx++;
        }

        if (hasSupReportToday) {
            currentSup = currentPhys;
        }

        if (i >= startDay && i <= endDay) {
            physicalSpots.add(FlSpot(i.toDouble(), currentPhys));
            supervisorSpots.add(FlSpot(i.toDouble(), currentSup));
        }
    }

    if (physicalSpots.isEmpty) {
        physicalSpots.add(FlSpot(startDay.toDouble(), 0));
        supervisorSpots.add(FlSpot(startDay.toDouble(), 0));
    }

    double xInterval = windowSize == 7 ? 1 : (windowSize == 30 ? 5 : math.max(1, (totalProjectDays / 5).ceilToDouble()));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5]);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                // Prevent overlap at edges
                if (windowSize > 7 && (value == startDay || value == endDay)) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('H${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: startDay.toDouble(),
        maxX: endDay.toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: physicalSpots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: const Color(0xFF00C853),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C853).withOpacity(0.2),
                  const Color(0xFF00C853).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: supervisorSpots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: const Color(0xFF001AFF),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF1E1E1E),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final isFisik = touchedSpot.barIndex == 0;
                return LineTooltipItem(
                  '${isFisik ? 'Fisik' : 'Pengawasan'} H${touchedSpot.x.toInt()}\n${touchedSpot.y.toStringAsFixed(1)}%',
                  TextStyle(color: isFisik ? const Color(0xFF00C853) : const Color(0xFF82B1FF), fontWeight: FontWeight.bold, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
