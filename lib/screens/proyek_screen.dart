import 'package:flutter/material.dart';
import '../widgets/project_card.dart';

class ProyekScreen extends StatefulWidget {
  const ProyekScreen({super.key});

  @override
  State<ProyekScreen> createState() => _ProyekScreenState();
}

class _ProyekScreenState extends State<ProyekScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Mock project database
  final List<Map<String, dynamic>> _allProjects = [
    {
      'title': 'Pembangunan Jembatan',
      'location': 'Purwokerto',
      'status': 'Progres',
      'physicalProgress': 0.80,
      'financialProgress': 0.50,
      'imageUrl': 'https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Gor hebat mantap',
      'location': 'Purbalingga',
      'status': 'Selesai',
      'physicalProgress': 1.00,
      'financialProgress': 1.00,
      'imageUrl': 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Gorong Gorong Manukan',
      'location': 'Surabaya',
      'status': 'Selesai',
      'physicalProgress': 1.00,
      'financialProgress': 1.00,
      'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Pengecoran Jalan Desa',
      'location': 'Kebumen',
      'status': 'Progres',
      'physicalProgress': 0.14,
      'financialProgress': 0.20,
      'imageUrl': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Rebuild on tab switch
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter projects by both tab status and search query
  List<Map<String, dynamic>> _getFilteredProjects() {
    // 1. Filter by Tab index
    List<Map<String, dynamic>> tabFiltered;
    switch (_tabController.index) {
      case 1: // Progres
        tabFiltered = _allProjects.where((p) => p['status'].toLowerCase() == 'progres').toList();
        break;
      case 2: // Selesai
        tabFiltered = _allProjects.where((p) => p['status'].toLowerCase() == 'selesai').toList();
        break;
      case 3: // Dibatalkan (Empty in mock data)
        tabFiltered = _allProjects.where((p) => p['status'].toLowerCase() == 'dibatalkan').toList();
        break;
      default: // Semua
        tabFiltered = List.from(_allProjects);
        break;
    }

    // 2. Filter by search query
    if (_searchQuery.isNotEmpty) {
      tabFiltered = tabFiltered.where((p) {
        final title = p['title'].toString().toLowerCase();
        final loc = p['location'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || loc.contains(query);
      }).toList();
    }

    return tabFiltered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredProjects();

    return Column(
      children: [
        // Search and Filter Row
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
          child: Row(
            children: [
              // Search Field
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontFamily: 'Inter',
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari Proyek..',
                      hintStyle: TextStyle(
                        color: Color(0xFFB0B3BE),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFFB0B3BE),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Filter Funnel Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.filter_alt_outlined,
                    color: Color(0xFF001AFF), // Blue color from design
                    size: 22,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter bottom sheet opened.')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // "+ Tambah Proyek" Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tambah Proyek clicked.')),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Tambah Proyek',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Tabs Header
        Container(
          color: Colors.white,
          width: double.infinity,
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF001AFF),
            indicatorWeight: 2.0,
            labelColor: const Color(0xFF001AFF),
            unselectedLabelColor: const Color(0xFFB0B3BE),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: const Color(0xFFF0F1F5),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Progres'),
              Tab(text: 'Selesai'),
              Tab(text: 'Dibatalkan'),
            ],
          ),
        ),

        // Projects List Area
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada proyek ditemukan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final project = filtered[index];
                    return ProjectCard(
                      title: project['title'],
                      location: project['location'],
                      status: project['status'],
                      physicalProgress: project['physicalProgress'],
                      financialProgress: project['financialProgress'],
                      imageUrl: project['imageUrl'],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
