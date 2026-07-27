import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/project_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/project_model.dart';
import 'project_controller.dart';
import '../../../widgets/mock_image_picker.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        _updateProjects();
      }
    });
    Future.microtask(() => _updateProjects());
  }

  void _updateProjects() {
    final status = switch (_tabController.index) {
      1 => 'Progres',
      2 => 'Selesai',
      _ => 'Semua',
    };
    ref.read(projectsControllerProvider.notifier).loadProjects(
      search: _searchQuery,
      status: status,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProjectDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ownerDetailCtrl = TextEditingController(text: 'Pemerintah Kabupaten Banyumas');
    final sourceCtrl = TextEditingController(text: 'APBD 2026');
    
    String selectedOwner = 'Budi Kontraktor';
    String selectedSupervisor = 'Aradea Kingdom';
    
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 180));
    
    // null = no image picked yet (no dummy fallback)
    String? selectedImagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          String formatDate(DateTime d) {
            final months = [
              '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
              'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
            ];
            return '${d.day} ${months[d.month]} ${d.year}';
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tambah Proyek Baru',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => Navigator.of(ctx).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image picker section
                      const Text(
                        'Foto Cover Proyek',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final path = await AppImagePicker.pickImage(context);
                          if (path != null) {
                            setDialogState(() => selectedImagePath = path);
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: selectedImagePath != null
                                  ? Image.file(
                                      File(selectedImagePath!),
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 120,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F1F5),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF001AFF), size: 32),
                                          SizedBox(height: 6),
                                          Text('Tap untuk tambah foto cover', style: TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
                                        ],
                                      ),
                                    ),
                            ),
                            if (selectedImagePath != null) ...[  
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child: Icon(Icons.camera_alt, color: Color(0xFF001AFF), size: 18),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Project Name
                      TextFormField(
                        controller: nameCtrl,
                        style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'Nama Proyek',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12.5),
                          prefixIcon: const Icon(Icons.business_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama proyek wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Location
                      TextFormField(
                        controller: locCtrl,
                        style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'Lokasi Proyek',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12.5),
                          prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Lokasi proyek wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Contractor dropdown
                      DropdownButtonFormField<String>(
                        value: selectedOwner,
                        style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter', color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Kontraktor Pelaksana',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12.5),
                          prefixIcon: const Icon(Icons.engineering_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Budi Kontraktor', child: Text('Budi Kontraktor')),
                          DropdownMenuItem(value: 'Koko Kontraktor', child: Text('Koko Kontraktor')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedOwner = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Supervisor dropdown
                      DropdownButtonFormField<String>(
                        value: selectedSupervisor,
                        style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter', color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Konsultan Pengawas',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12.5),
                          prefixIcon: const Icon(Icons.assignment_ind_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Aradea Kingdom', child: Text('Aradea Kingdom')),
                          DropdownMenuItem(value: 'Onic P.', child: Text('Onic P.')),
                          DropdownMenuItem(value: 'Aura F.', child: Text('Aura F.')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedSupervisor = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Date Pickers Row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) {
                                  setDialogState(() {
                                    startDate = d;
                                    if (endDate.isBefore(startDate)) {
                                      endDate = startDate.add(const Duration(days: 30));
                                    }
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Tgl Mulai',
                                    labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11),
                                    hintText: formatDate(startDate),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  ),
                                  style: const TextStyle(fontSize: 11.5, fontFamily: 'Inter'),
                                  controller: TextEditingController(text: formatDate(startDate)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: endDate,
                                  firstDate: startDate,
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) {
                                  setDialogState(() => endDate = d);
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Tgl Selesai',
                                    labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11),
                                    hintText: formatDate(endDate),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    prefixIcon: const Icon(Icons.calendar_month_rounded, size: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  ),
                                  style: const TextStyle(fontSize: 11.5, fontFamily: 'Inter'),
                                  controller: TextEditingController(text: formatDate(endDate)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Owner detail (Instansi Pemilik)
                      TextFormField(
                        controller: ownerDetailCtrl,
                        style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'Pemilik Proyek (Instansi)',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12.5),
                          prefixIcon: const Icon(Icons.account_balance_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Funding source
                      TextFormField(
                        controller: sourceCtrl,
                        style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'Sumber Dana',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12.5),
                          prefixIcon: const Icon(Icons.monetization_on_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Proyek',
                          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12.5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final newProj = ProjectModel(
                    id: const Uuid().v4(),
                    name: nameCtrl.text,
                    location: locCtrl.text,
                    status: 'Progres',
                    physicalProgress: 0.0,
                    financialProgress: 0.0,
                    imageUrl: selectedImagePath ?? '',
                    description: descCtrl.text,
                    owner: selectedOwner,
                    supervisor: selectedSupervisor,
                    createdAt: DateTime.now().toString().substring(0, 10),
                    startDate: formatDate(startDate),
                    endDate: formatDate(endDate),
                    ownerDetail: ownerDetailCtrl.text,
                    fundingSource: sourceCtrl.text,
                  );
                  await ref.read(projectsControllerProvider.notifier).addProject(newProj);
                  _updateProjects();
                  if (mounted) Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  elevation: 0,
                ),
                child: const Text('Simpan', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final userRole = user?.role ?? AppRole.eksternal;

    final projectsState = ref.watch(projectsControllerProvider);
    final rawProjects = projectsState.valueOrNull ?? [];
    
    final filtered = rawProjects.where((p) {
      if (userRole == AppRole.kontraktor) {
        return p.owner == user?.name;
      } else if (userRole == AppRole.eksternal) {
        return p.id == 'project-1';
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _searchQuery = value;
                      _updateProjects();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari Proyek..',
                      hintStyle: TextStyle(color: Color(0xFFB0B3BE), fontSize: 13, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFFB0B3BE), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
                child: IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF001AFF), size: 22),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter status proyek lokal aktif.')));
                  },
                ),
              ),
            ],
          ),
        ),
        if (userRole.canCreateProject)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _showAddProjectDialog,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Tambah Proyek Baru', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  elevation: 0,
                ),
              ),
            ),
          ),

        const SizedBox(height: 4),
        TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF001AFF),
          labelColor: const Color(0xFF001AFF),
          unselectedLabelColor: const Color(0xFFB0B3BE),
          tabs: const [Tab(text: 'Semua'), Tab(text: 'Progres'), Tab(text: 'Selesai')],
        ),
        Expanded(
          child: projectsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: Text('Tidak ada proyek ditemukan', style: TextStyle(fontFamily: 'Inter', color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final project = filtered[index];
                        return ProjectCard(
                          projectId: project.id,
                          title: project.name,
                          location: project.location,
                          status: project.status,
                          physicalProgress: project.physicalProgress,
                          financialProgress: project.financialProgress,
                          imageUrl: project.imageUrl,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
