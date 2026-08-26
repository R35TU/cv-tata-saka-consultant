import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/project_controller.dart';
import '../../projects/data/models/project_model.dart';
import 'report_controller.dart';

class RekapLaporanScreen extends ConsumerStatefulWidget {
  const RekapLaporanScreen({super.key});

  @override
  ConsumerState<RekapLaporanScreen> createState() => _RekapLaporanScreenState();
}

class _RekapLaporanScreenState extends ConsumerState<RekapLaporanScreen> {
  String? _selectedProjectId;
  String _selectedPeriod = 'Bulanan';
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(projectsControllerProvider.notifier).loadProjects();
      ref.read(contractorReportsProvider.notifier).loadReports();
    });
  }

  void _simulatePDFExport(ProjectModel? selectedProject) {
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
                  _showPDFPreviewSheet(selectedProject);
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

  void _showPDFPreviewSheet(ProjectModel project) {
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
                            _pdfRow('Kemajuan Fisik Saat Ini', '${(project.physicalProgress * 100).toInt()}%'),
                            _pdfRow('Kemajuan Finansial', '${(project.financialProgress * 100).toInt()}%'),
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
    final projectsState = ref.watch(projectsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];

    // Resolve selected project
    final selectedProject = _selectedProjectId != null
        ? projects.firstWhere((p) => p.id == _selectedProjectId)
        : (projects.isNotEmpty ? projects.first : null);

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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Periode', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    value: _selectedPeriod,
                                    items: const [
                                      DropdownMenuItem(value: 'Mingguan', child: Text('Mingguan')),
                                      DropdownMenuItem(value: 'Bulanan', child: Text('Bulanan')),
                                    ],
                                    onChanged: (val) => setState(() => _selectedPeriod = val!),
                                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Status Laporan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    value: _selectedStatus,
                                    items: const [
                                      DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                                      DropdownMenuItem(value: 'DISETUJUI', child: Text('Disetujui')),
                                      DropdownMenuItem(value: 'DITOLAK', child: Text('Ditolak')),
                                      DropdownMenuItem(value: 'MENUNGGU VERIFIKASI', child: Text('Menunggu')),
                                    ],
                                    onChanged: (val) => setState(() => _selectedStatus = val!),
                                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                  Text('${(selectedProject.physicalProgress * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C853))),
                                ],
                              ),
                              Container(height: 30, width: 1, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('Keuangan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  Text('${(selectedProject.financialProgress * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF001AFF))),
                                ],
                              ),
                              Container(height: 30, width: 1, color: Colors.grey.shade300),
                              const Column(
                                children: [
                                  Text('Laporan Harian', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  SizedBox(height: 6),
                                  Text('3 Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
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
                          const Text('Kurva Kemajuan S-Curve (Simulasi)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Inter')),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBarChartCol('M1', 0.15, const Color(0xFF001AFF)),
                              _buildBarChartCol('M2', 0.35, const Color(0xFF001AFF)),
                              _buildBarChartCol('M3', 0.50, const Color(0xFF001AFF)),
                              _buildBarChartCol('M4', selectedProject.physicalProgress, const Color(0xFF00C853)), // Current
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Export PDF Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _simulatePDFExport(selectedProject),
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

  Widget _buildBarChartCol(String week, double progress, Color color) {
    return Column(
      children: [
        Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 120 * progress,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(week, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
