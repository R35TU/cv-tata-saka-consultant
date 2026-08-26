import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/project_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/project_model.dart';
import 'project_controller.dart';
import '../../../widgets/mock_image_picker.dart';
import 'add_contract_screen.dart';

class ContractListScreen extends ConsumerStatefulWidget {
  const ContractListScreen({super.key});

  @override
  ConsumerState<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends ConsumerState<ContractListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTypeFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _updateContracts());
  }

  void _updateContracts() {
    ref.read(contractsControllerProvider.notifier).loadProjects(
      search: _searchQuery,
      type: _selectedTypeFilter,
      status: 'Semua',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContractScreen()),
    );
    if (result == true) {
      _updateContracts();
    }
  }

  void _navigateToEditProject(ContractModel project) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddContractScreen(contract: project)),
    );
    if (result == true) {
      _updateContracts();
    }
  }

  void _showDeleteProjectDialog(ContractModel project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kontrak', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Apakah Anda yakin ingin menghapus kontrak "${project.name}"? Semua data terkait (Sub-kegiatan, dokumen, folder) mungkin akan terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              ref.read(contractsControllerProvider.notifier).deleteContract(project.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final userRole = user?.role ?? AppRole.eksternal;

    final contractsState = ref.watch(contractsControllerProvider);
    final rawContracts = contractsState.valueOrNull ?? [];
    
    final filtered = rawContracts;

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
                      _updateContracts();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari Kontrak..',
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
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF001AFF), size: 22),
                  tooltip: 'Filter Jenis Kegiatan',
                  initialValue: _selectedTypeFilter,
                  onSelected: (value) {
                    setState(() {
                      _selectedTypeFilter = value;
                    });
                    _updateContracts();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Semua', child: Text('Semua Jenis')),
                    const PopupMenuItem(value: 'Pengawasan Teknis', child: Text('Pengawasan Teknis')),
                    const PopupMenuItem(value: 'Perencanaan Teknis', child: Text('Perencanaan Teknis')),
                  ],
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
                onPressed: _navigateToAddProject,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Tambah Kontrak Baru', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  elevation: 0,
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),
        Expanded(
          child: contractsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: Text('Tidak ada kontrak ditemukan', style: TextStyle(fontFamily: 'Inter', color: Colors.grey)))
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
                          physicalProgress: 0.0,
                          financialProgress: 0.0,
                          imageUrl: project.imageUrl,
                          onEdit: userRole.canCreateProject ? () => _navigateToEditProject(project) : null,
                          onDelete: userRole.canCreateProject ? () => _showDeleteProjectDialog(project) : null,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
