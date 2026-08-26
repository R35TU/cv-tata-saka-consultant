import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import 'package:isar/isar.dart';
import '../data/models/project_model.dart';
import 'project_controller.dart';

class AddProjectScreen extends ConsumerStatefulWidget {
  final String contractId;

  const AddProjectScreen({super.key, required this.contractId});

  @override
  ConsumerState<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends ConsumerState<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _field4Ctrl = TextEditingController();
  final _field5Ctrl = TextEditingController();
  
  String _selectedContractor = '';
  List<String> _kontraktorUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = await IsarDatabaseService.db;
    final allUsers = await isar.userIsars.where().findAll();
    final kontraktorUsers = allUsers.where((u) => u.role == 'Kontraktor').map((u) => u.name).toList();
    
    if (kontraktorUsers.isEmpty) kontraktorUsers.add('Budi Kontraktor');
    
    setState(() {
      _kontraktorUsers = kontraktorUsers;
      _selectedContractor = kontraktorUsers.first;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _field4Ctrl.dispose();
    _field5Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Proyek Baru',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Nama Proyek',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.business_rounded, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama proyek wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locCtrl,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Lokasi',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.location_on_rounded, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Contractor dropdown
              DropdownButtonFormField<String>(
                value: _selectedContractor,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Kontraktor Pelaksana',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.engineering_outlined, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _kontraktorUsers.map((name) => 
                  DropdownMenuItem(value: name, child: Text(name))
                ).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedContractor = val);
                },
              ),
              const SizedBox(height: 16),

              // Gimmick Field 4
              TextFormField(
                controller: _field4Ctrl,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Keterangan Tambahan 1 (Opsional)',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Gimmick Field 5
              TextFormField(
                controller: _field5Ctrl,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Keterangan Tambahan 2 (Opsional)',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.note_alt_outlined, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              
              String desc = '';
              if (_field4Ctrl.text.isNotEmpty) desc += 'Ket 1: ${_field4Ctrl.text}\n';
              if (_field5Ctrl.text.isNotEmpty) desc += 'Ket 2: ${_field5Ctrl.text}';

              final newProj = ProjectModel(
                id: const Uuid().v4(),
                contractId: widget.contractId,
                name: _nameCtrl.text,
                location: _locCtrl.text,
                contractor: _selectedContractor,
                description: desc.trim(),
                status: 'Progres',
                physicalProgress: 0.0,
                financialProgress: 0.0,
              );
              await ref.read(contractsControllerProvider.notifier).addProject(newProj);
              if (mounted) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              elevation: 0,
            ),
            child: const Text('Simpan Proyek', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
