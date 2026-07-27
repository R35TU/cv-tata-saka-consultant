import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../projects/presentation/project_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/report_model.dart';
import 'report_controller.dart';
import '../../../widgets/mock_image_picker.dart';

class SupervisorReportForm extends ConsumerStatefulWidget {
  const SupervisorReportForm({super.key});

  @override
  ConsumerState<SupervisorReportForm> createState() => _SupervisorReportFormState();
}

class _SupervisorReportFormState extends ConsumerState<SupervisorReportForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProjectId;
  final _locationCtrl = TextEditingController();
  final _weatherCtrl = TextEditingController(text: 'Cerah');
  final _findingsCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _recsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final List<String> _photos = [];
  final List<String> _attachments = [];

  @override
  void dispose() {
    _locationCtrl.dispose();
    _weatherCtrl.dispose();
    _findingsCtrl.dispose();
    _conditionsCtrl.dispose();
    _instructionsCtrl.dispose();
    _recsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMockPhoto() async {
    final path = await AppImagePicker.pickImage(context);
    if (path != null && mounted) {
      setState(() => _photos.add(path));
    }
  }

  void _addMockAttachment() {
    setState(() {
      _attachments.add('Instruksi_Pekerjaan_${_attachments.length + 1}.pdf');
    });
  }

  void _submit(String supervisorName) async {
    if (!_formKey.currentState!.validate() || _selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi formulir pengawasan.')));
      return;
    }

    final report = SupervisorReportModel(
      id: const Uuid().v4(),
      projectId: _selectedProjectId!,
      date: DateTime.now().toString().substring(0, 10),
      time: DateTime.now().toString().substring(11, 16),
      supervisorName: supervisorName,
      location: _locationCtrl.text,
      weather: _weatherCtrl.text,
      findings: _findingsCtrl.text,
      fieldConditions: _conditionsCtrl.text,
      instructions: _instructionsCtrl.text,
      recommendations: _recsCtrl.text,
      notes: _notesCtrl.text,
      photos: _photos,
      attachments: _attachments,
    );

    await ref.read(supervisorReportsProvider.notifier).submitReport(report);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan pengawasan harian berhasil disimpan.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final supervisorName = user?.name ?? 'Konsultan';

    final projectsState = ref.watch(projectsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Buat Laporan Pengawasan', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE8F9EE), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF00C853))),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Color(0xFF00C853)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pengawas / Auditor:', style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Inter')),
                        Text(supervisorName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Project Selection
              const Text('Pilih Proyek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E1E1E))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (val) => setState(() => _selectedProjectId = val),
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              ),
              const SizedBox(height: 16),

              // Location & Weather
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lokasi / STA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(controller: _locationCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Jembatan STA 12...')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cuaca', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(controller: _weatherCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Cerah/Berawan...')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Findings (Temuan)
              const Text('Temuan Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _findingsCtrl, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Temuan atau ketidaksesuaian...')),
              const SizedBox(height: 16),

              // Field Conditions (Kondisi Lapangan)
              const Text('Kondisi Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _conditionsCtrl, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Kondisi tanah, beton, dll...')),
              const SizedBox(height: 16),

              // Instructions (Instruksi)
              const Text('Instruksi kepada Kontraktor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _instructionsCtrl, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Lakukan perbaikan bekisting...')),
              const SizedBox(height: 16),

              // Recommendations (Rekomendasi)
              const Text('Rekomendasi Pengawas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _recsCtrl, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Rekomendasi metode pengecoran...')),
              const SizedBox(height: 16),

              // Notes (Catatan)
              const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _notesCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
              const SizedBox(height: 24),

              // Photo Documentation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Foto Pengawasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  TextButton.icon(onPressed: _addMockPhoto, icon: const Icon(Icons.add_photo_alternate_outlined, size: 18), label: const Text('Tambah Foto', style: TextStyle(fontSize: 12))),
                ],
              ),
              const SizedBox(height: 6),
              if (_photos.isEmpty)
                Container(
                  height: 80,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                  child: const Text('Belum ada foto dokumentasi', style: TextStyle(color: Colors.grey, fontSize: 11)),
                )
              else
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    itemBuilder: (context, idx) {
                      final p = _photos[idx];
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
              const SizedBox(height: 20),

              // Attachments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lampiran Instruksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  TextButton.icon(onPressed: _addMockAttachment, icon: const Icon(Icons.attach_file_rounded, size: 18), label: const Text('Tambah File', style: TextStyle(fontSize: 12))),
                ],
              ),
              const SizedBox(height: 6),
              if (_attachments.isEmpty)
                Container(
                  height: 60,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                  child: const Text('Belum ada lampiran file', style: TextStyle(color: Colors.grey, fontSize: 11)),
                )
              else
                Column(
                  children: _attachments.map((file) => Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFF0F1F5))),
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                      title: Text(file, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                        onPressed: () => setState(() => _attachments.remove(file)),
                      ),
                    ),
                  )).toList(),
                ),
              const SizedBox(height: 36),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _submit(supervisorName),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Simpan Laporan Pengawasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
