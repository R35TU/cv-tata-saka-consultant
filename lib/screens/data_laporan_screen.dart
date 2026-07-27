import 'package:flutter/material.dart';
import '../widgets/data_laporan_card.dart';
import 'detail_data_laporan_screen.dart';

/// Data model for a single project entry in Data Laporan.
class _ProyekData {
  final String title;
  final String location;
  final String status; // "Progres" | "Selesai"
  final double physicalProgress;
  final double financialProgress;

  final String imageUrl;

  const _ProyekData({
    required this.title,
    required this.location,
    required this.status,
    required this.physicalProgress,
    required this.financialProgress,
    required this.imageUrl,
  });
}

/// Full-screen page for "Data Laporan" with search + filter tabs + project list.
class DataLaporanScreen extends StatefulWidget {
  const DataLaporanScreen({super.key});

  @override
  State<DataLaporanScreen> createState() => _DataLaporanScreenState();
}

class _DataLaporanScreenState extends State<DataLaporanScreen> {
  // Filter options
  static const List<String> _filterLabels = ['Semua', 'On Progress', 'Selesai'];
  int _selectedFilter = 0;

  // Search query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dummy data
  static const List<_ProyekData> _allProjects = [
    _ProyekData(
      title: 'Pembangunan Jembatan',
      location: 'Purwokerto',
      status: 'Progres',
      physicalProgress: 0.80,
      financialProgress: 0.50,
      imageUrl: 'https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=600&auto=format&fit=crop',
    ),
    _ProyekData(
      title: 'Gor Hebat Mantap',
      location: 'Purbalingga',
      status: 'Selesai',
      physicalProgress: 1.00,
      financialProgress: 1.00,
      imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?q=80&w=600&auto=format&fit=crop',
    ),
    _ProyekData(
      title: 'Gorong Gorong Manukan',
      location: 'Surabaya',
      status: 'Selesai',
      physicalProgress: 1.00,
      financialProgress: 1.00,
      imageUrl: 'https://images.unsplash.com/photo-1488972685288-c3fd157d7c7a?q=80&w=600&auto=format&fit=crop',
    ),
    _ProyekData(
      title: 'Aspal Jl.Desa Kesugihan',
      location: 'Cilacap',
      status: 'Progres',
      physicalProgress: 0.80,
      financialProgress: 0.50,
      imageUrl: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?q=80&w=600&auto=format&fit=crop',
    ),
    _ProyekData(
      title: 'Koperasi Hitam Putih',
      location: 'Alam Lain',
      status: 'Progres',
      physicalProgress: 0.10,
      financialProgress: 0.10,
      imageUrl: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?q=80&w=600&auto=format&fit=crop',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ProyekData> get _filteredProjects {
    return _allProjects.where((p) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.location.toLowerCase().contains(_searchQuery.toLowerCase());

      // Tab filter
      final matchesTab = switch (_selectedFilter) {
        1 => p.status.toLowerCase() == 'progres',
        2 => p.status.toLowerCase() == 'selesai',
        _ => true,
      };

      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Inter',
                color: Color(0xFF1E1E1E),
              ),
              decoration: InputDecoration(
                hintText: 'Cari Proyek..',
                hintStyle: const TextStyle(
                  color: Color(0xFFB0B3BE),
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFB0B3BE),
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF001AFF),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // ── Filter tabs ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F5),
                borderRadius: BorderRadius.circular(10.0),
              ),
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
                          color: isSelected
                              ? const Color(0xFF001AFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _filterLabels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Project list ─────────────────────────────────────────────────
          Expanded(
            child: _filteredProjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 44, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada proyek ditemukan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      return DataLaporanCard(
                        title: project.title,
                        location: project.location,
                        status: project.status,
                        physicalProgress: project.physicalProgress,
                        financialProgress: project.financialProgress,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailDataLaporanScreen(
                              projectTitle: project.title,
                              projectStatus: project.status,
                              projectImageUrl: project.imageUrl,
                            ),
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
