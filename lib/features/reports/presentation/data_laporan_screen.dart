import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/data_laporan_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../projects/presentation/project_controller.dart';
import 'detail_data_laporan_screen.dart';

class DataLaporanScreen extends ConsumerStatefulWidget {
  const DataLaporanScreen({super.key});

  @override
  ConsumerState<DataLaporanScreen> createState() => _DataLaporanScreenState();
}

class _DataLaporanScreenState extends ConsumerState<DataLaporanScreen> {
  static const List<String> _filterLabels = ['Semua', 'On Progress', 'Selesai'];
  int _selectedFilter = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(contractsControllerProvider.notifier).loadProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final userRole = user?.role ?? AppRole.eksternal;

    final projectsState = ref.watch(contractsControllerProvider);
    final rawProjects = projectsState.valueOrNull ?? [];

    // Filter projects based on role
    final projects = rawProjects.where((project) {
      if (userRole == AppRole.kontraktor) {
        return project.owner == user?.name;
      }
      // konsultan, dinas, dan eksternal melihat semua proyek
      return true;
    }).toList();

    // Filter projects by search query and tab index
    final filteredProjects = projects.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesTab = switch (_selectedFilter) {
        1 => p.status.toLowerCase() == 'progres',
        2 => p.status.toLowerCase() == 'selesai',
        _ => true,
      };

      return matchesSearch && matchesTab;
    }).toList();

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
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Color(0xFF1E1E1E)),
              decoration: InputDecoration(
                hintText: 'Cari Proyek..',
                hintStyle: const TextStyle(color: Color(0xFFB0B3BE), fontSize: 13, fontFamily: 'Inter'),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB0B3BE), size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Color(0xFF001AFF), width: 1.0)),
              ),
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF0F1F5), borderRadius: BorderRadius.circular(10.0)),
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: List.generate(_filterLabels.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF001AFF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _filterLabels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Project List
          Expanded(
            child: projectsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 44, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak ada proyek ditemukan',
                              style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index];
                          return DataLaporanCard(
                            title: project.name,
                            location: project.location,
                            status: project.status,
                            physicalProgress: 0.0,
                            financialProgress: 0.0,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailDataLaporanScreen(projectId: project.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
