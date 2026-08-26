import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../projects/presentation/project_controller.dart';
import '../data/models/report_model.dart';
import 'report_controller.dart';
import '../../../widgets/mock_image_picker.dart';
import '../../auth/presentation/auth_controller.dart';

class ContractorReportForm extends ConsumerStatefulWidget {
  final ContractorReportModel? existingReport; // If editing a rejected report

  const ContractorReportForm({super.key, this.existingReport});

  @override
  ConsumerState<ContractorReportForm> createState() => _ContractorReportFormState();
}

class _ContractorReportFormState extends ConsumerState<ContractorReportForm> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedProjectId;
  final _locationCtrl = TextEditingController();
  final _weatherCtrl = TextEditingController(text: 'Cerah');
  final _progressCtrl = TextEditingController(text: '0'); // Percentage
  final _tasksCtrl = TextEditingController();
  final _materialsCtrl = TextEditingController();
  final _toolsCtrl = TextEditingController();
  final _workersCtrl = TextEditingController();
  final _obstaclesCtrl = TextEditingController();
  final _solutionsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  final List<String> _photos = [];
  final List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingReport != null) {
      final rep = widget.existingReport!;
      _selectedProjectId = rep.projectId;
      _locationCtrl.text = rep.location;
      _weatherCtrl.text = rep.weather;
      _progressCtrl.text = (rep.todayProgress * 100).toInt().toString();
      _tasksCtrl.text = rep.tasksDone;
      _materialsCtrl.text = rep.materialsUsed;
      _toolsCtrl.text = rep.toolsUsed;
      _workersCtrl.text = rep.workersCount;
      _obstaclesCtrl.text = rep.obstacles;
      _solutionsCtrl.text = rep.solutions;
      _notesCtrl.text = rep.notes;
      _photos.addAll(rep.photos);
      _attachments.addAll(rep.attachments);
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _weatherCtrl.dispose();
    _progressCtrl.dispose();
    _tasksCtrl.dispose();
    _materialsCtrl.dispose();
    _toolsCtrl.dispose();
    _workersCtrl.dispose();
    _obstaclesCtrl.dispose();
    _solutionsCtrl.dispose();
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
      _attachments.add('Lampiran_Laporan_${_attachments.length + 1}.pdf');
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi formulir laporan.')));
      return;
    }

    final double progVal = (double.tryParse(_progressCtrl.text) ?? 0.0) / 100.0;
    
    final user = ref.read(authControllerProvider).valueOrNull;
    final userName = user?.name ?? 'Budi Kontraktor';

    final changeHistory = widget.existingReport != null
        ? [
            ...widget.existingReport!.changeHistory,
            ReportHistory(
              date: DateTime.now().toString().substring(0, 16),
              user: userName,
              action: 'Revisi & Kirim Ulang',
              details: 'Laporan diperbaiki dan dikirim ulang untuk verifikasi.',
            ),
          ]
        : [
            ReportHistory(
              date: DateTime.now().toString().substring(0, 16),
              user: userName,
              action: 'Dibuat',
              details: 'Laporan dibuat pertama kali.',
            ),
          ];

    final report = ContractorReportModel(
      id: const Uuid().v4(),
      projectId: _selectedProjectId!,
      date: DateTime.now().toString().substring(0, 10),
      time: DateTime.now().toString().substring(11, 16),
      weather: _weatherCtrl.text,
      location: _locationCtrl.text,
      todayProgress: progVal,
      tasksDone: _tasksCtrl.text,
      materialsUsed: _materialsCtrl.text,
      toolsUsed: _toolsCtrl.text,
      workersCount: _workersCtrl.text,
      obstacles: _obstaclesCtrl.text,
      solutions: _solutionsCtrl.text,
      notes: _notesCtrl.text,
      photos: _photos,
      attachments: _attachments,
      status: 'MENUNGGU VERIFIKASI',
      changeHistory: changeHistory,
    );

    // If revising, mark the old report as DIREVISI
    if (widget.existingReport != null) {
      await ref.read(contractorReportsProvider.notifier).markAsRevised(widget.existingReport!.id);
    }

    await ref.read(contractorReportsProvider.notifier).submitReport(report);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan harian berhasil dikirim ke Pengawas.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(contractsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];
    
    final user = ref.watch(authControllerProvider).valueOrNull;
    
    // Contractors only see their assigned projects
    final contractorProjects = projects.where((p) => p.owner == user?.name).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)), onPressed: () => Navigator.of(context).pop()),
        title: Text(widget.existingReport != null ? 'Revisi Laporan Harian' : 'Buat Laporan Kontraktor', style: const TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 16)),
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
              if (widget.existingReport != null && widget.existingReport!.revisionNotes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEF5350))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 18),
                          SizedBox(width: 6),
                          Text('Catatan Revisi Pengawas:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F), fontSize: 13, fontFamily: 'Inter')),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(widget.existingReport!.revisionNotes, style: const TextStyle(fontSize: 12.5, color: Color(0xFFC62828), height: 1.4, fontFamily: 'Inter')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Project Selector
              const Text('Pilih Proyek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E1E1E))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                items: contractorProjects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: widget.existingReport != null ? null : (val) => setState(() => _selectedProjectId = val),
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
                        TextFormField(controller: _locationCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'STA 13...')),
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
                        TextFormField(controller: _weatherCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Cerah/Hujan...')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress
              const Text('Progress Hari Ini (%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _progressCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Misal: 5')),
              const SizedBox(height: 16),

              // Tasks Done
              const Text('Pekerjaan Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _tasksCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Detail pekerjaan...')),
              const SizedBox(height: 16),

              // Materials
              const Text('Material yang Digunakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _materialsCtrl, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Semen, Pasir, Besi...')),
              const SizedBox(height: 16),

              // Tools
              const Text('Alat yang Digunakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _toolsCtrl, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Excavator, Mixer...')),
              const SizedBox(height: 16),

              // Workers
              const Text('Tenaga Kerja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _workersCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '10 Pekerja, 1 Mandor...')),
              const SizedBox(height: 16),

              // Obstacles & Solutions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kendala Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(controller: _obstaclesCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Hujan, Ban bocor...')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Solusi Kendala', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(controller: _solutionsCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Berteduh, Ganti ban...')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(controller: _notesCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
              const SizedBox(height: 24),

              // Photo Gallery (Seeded list)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Foto Dokumentasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
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
                  const Text('Lampiran Dokumen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
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
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001AFF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Kirim Laporan Harian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
