import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/progress_item.dart';
import '../widgets/dashboard_chart.dart';
import 'proyek_screen.dart';
import 'laporan_screen.dart';
import 'riwayat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Daftar Kontrak';
      case 2:
        return 'Laporan Kontrak';
      case 3:
        return 'Kronologi Kontrak';
      case 4:
        return 'Akun';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const ProyekScreen();
      case 2:
        return const LaporanScreen();
      case 3:
        return const RiwayatScreen();
      case 4:
        return _buildPlaceholder(_getAppBarTitle());
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Halaman $title sedang dikembangkan',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome User section
            const Text(
              'Selamat Datang,',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'CV. Tata Saka Konsultan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Konsultan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFA0A0A0),
                fontFamily: 'Inter',
              ),
            ),
            
            const SizedBox(height: 24),

            // Statistics Grid (2x2)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.35,
              children: const [
                StatCard(
                  title: 'Total Kontrak',
                  value: '5',
                  icon: Icons.folder,
                  iconColor: Color(0xFF001AFF),
                  iconBackgroundColor: Color(0xFFE5EAFF),
                ),
                StatCard(
                  title: 'Progres',
                  value: '3',
                  icon: Icons.bar_chart_rounded,
                  iconColor: Color(0xFF00C853),
                  iconBackgroundColor: Color(0xFFE8F9EE),
                ),
                StatCard(
                  title: 'Laporan Hari Ini',
                  value: '4',
                  icon: Icons.description_rounded,
                  iconColor: Color(0xFFFF9100),
                  iconBackgroundColor: Color(0xFFFFF4E5),
                ),
                StatCard(
                  title: 'Kontrak Selesai',
                  value: '2',
                  icon: Icons.check_box_rounded,
                  iconColor: Color(0xFF001AFF),
                  iconBackgroundColor: Color(0xFFE5EAFF),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Kontrak On Progress Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kontrak On Progress',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                    fontFamily: 'Inter',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to Projects Tab
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF001AFF),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // Kontrak On Progress Items
            const ProgressItem(
              title: 'Fly Over Jl. Jendral Sudirman',
              progress: 0.82,
              progressColor: Color(0xFF00C853), // Green progress
            ),
            const ProgressItem(
              title: 'Pembangunan Jembatan Sirothol Mustakim',
              progress: 0.38,
              progressColor: Color(0xFFFF9100), // Orange progress
            ),
            const ProgressItem(
              title: 'Pengecoran Jalan Desa Hebat Sekali',
              progress: 0.14,
              progressColor: Color(0xFFFF3D00), // Red progress
            ),

            const SizedBox(height: 28),

            // progres kontrak Circular Donut Card
            const DashboardChart(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFF0F1F5),
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E1E1E), size: 28),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu drawer clicked.')),
            );
          },
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF1E1E1E), size: 26),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications clicked.')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFF0F1F5),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF001AFF),
          unselectedItemColor: const Color(0xFFB0B3BE),
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              label: 'Proyek',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}
